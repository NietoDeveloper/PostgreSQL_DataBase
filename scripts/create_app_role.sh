#!/usr/bin/env bash
# Creates (or rotates the password of) the least-privilege LOGIN role the
# application should actually connect as — never the migration/owner role.
# The password is read from an env var, never written into version-controlled
# SQL, never echoed, and never placed on the command line (which would leak
# into shell history / `ps`).
set -euo pipefail

: "${DATABASE_URL:?Set DATABASE_URL to the bootstrap/owner connection string first}"
: "${APP_DB_PASSWORD:?Set APP_DB_PASSWORD to a strong, generated password for app_user}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -v pass="$APP_DB_PASSWORD" <<'SQL'
SELECT format('ALTER ROLE app_user WITH LOGIN PASSWORD %L', :'pass')
WHERE EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user')
UNION ALL
SELECT format('CREATE ROLE app_user LOGIN PASSWORD %L CONNECTION LIMIT 50', :'pass')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user');
\gexec

GRANT app_rw TO app_user;
SQL

echo "app_user is ready (member of app_rw). Rotate APP_DB_PASSWORD periodically."
