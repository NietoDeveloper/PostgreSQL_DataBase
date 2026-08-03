# Security Hardening Notes

This schema ships with a set of security defaults baked in. This document
explains what they are and what still depends on you / your deployment
environment.

## What's enforced at the database layer

- **Least-privilege roles.** `009_security_hardening.sql` creates two group
  roles — `app_rw` (read/write, for the application) and `app_ro`
  (read-only, for reporting/analytics) — and revokes all default `PUBLIC`
  privileges on the schema. `scripts/create_app_role.sh` creates the actual
  `app_user` LOGIN role and adds it to `app_rw`. **The application should
  never connect using the Docker `POSTGRES_USER` (owner) role** — that role
  exists only to run migrations.
- **Row-Level Security (RLS).** `users`, `sessions`, `notifications`, and
  `user_settings` have RLS enabled: a connection can only see/modify rows
  belonging to `current_setting('app.current_user_id')`, unless the
  connection explicitly sets `app.is_admin = 'true'` for a privileged
  service operation. Your application should run
  `SET LOCAL app.current_user_id = '<uuid>';` at the start of each
  request/transaction.
- **Append-only audit log.** `audit_log` grants `SELECT, INSERT` only —
  `UPDATE`, `DELETE`, and `TRUNCATE` are revoked from every role, including
  `app_rw`. Rows are only ever written by the `audit_row_change()` trigger.
- **Hashed session tokens.** `sessions.refresh_token_hash` stores a SHA-256
  (or stronger) hash computed by the application — never the raw refresh
  token. A leaked backup does not leak usable sessions.
- **Brute-force lockout.** `users.failed_login_attempts` /
  `users.locked_until`, managed via `register_failed_login()`,
  `register_successful_login()`, and `is_account_locked()` — call these
  instead of writing to the columns directly so the lockout policy stays in
  one place.
- **Search-path pinning.** Every function sets `search_path = public,
  pg_temp` explicitly, and the audit trigger runs `SECURITY DEFINER`, so a
  low-privileged caller can't hijack it by manipulating `search_path`.
- **Data-shape constraints.** Basic `CHECK` constraints on email format,
  username length, and password-hash length catch obviously malformed data
  before it lands in the table (this is defense in depth, not a substitute
  for application-level validation).
- **Per-role connection limits.** `statement_timeout` and
  `idle_in_transaction_session_timeout` are set on both `app_rw` and
  `app_ro` so a runaway query or an abandoned transaction can't hold locks
  indefinitely.

## What you still need to do

- **Never commit real credentials.** `.env.example` ships with empty
  passwords on purpose — generate strong ones (`openssl rand -base64 32`)
  per environment and keep `.env` out of version control (already in
  `.gitignore`).
- **Require TLS in any non-local environment.** Add `sslmode=require` (or
  `verify-full` with a CA bundle) to every connection string once this
  database isn't running on `localhost`.
- **Rotate `APP_DB_PASSWORD` periodically** by re-running
  `scripts/create_app_role.sh` with a new value.
- **Don't publish the Postgres port publicly.** `docker-compose.yml` binds
  to `127.0.0.1` by default — keep it that way unless you have a specific,
  firewalled reason not to.
- **Back up `pg_hba.conf` / managed-provider network rules** if you deploy
  to a managed Postgres service — the RLS policies here protect rows
  *within* a connection, not the network path to the database itself.
- **Review the RLS policies before adding new tables that hold user data** —
  RLS is opt-in per table; a new table isn't automatically covered.
