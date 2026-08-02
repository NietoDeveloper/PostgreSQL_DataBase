# Generic PostgreSQL Starter Database

A small, dependency-free PostgreSQL schema meant to be dropped into **any**
new project as a solid starting point: authentication, RBAC, audit trail,
file attachments, notifications, and a settings store — all with UUID keys,
timestamps, and soft deletes already wired up.

## Stack

- PostgreSQL 16
- Plain SQL migrations (no ORM lock-in — works with Prisma, TypeORM, Sequelize, Knex, raw `pg`, etc.)
- Docker Compose for local development

## Structure

```
.
├── migrations/                 # Run in numeric order
│   ├── 001_extensions.sql
│   ├── 002_schema_core.sql     # users, roles, permissions, sessions
│   ├── 003_schema_audit.sql    # audit_log
│   ├── 004_schema_files.sql    # attachments
│   ├── 005_schema_notifications.sql
│   ├── 006_schema_settings.sql # app_settings, user_settings
│   ├── 007_triggers_functions.sql
│   └── 008_seed.sql
├── scripts/
│   ├── init.sh                 # applies all migrations
│   └── reset.sh                # drops & re-applies everything (destructive)
├── docs/
│   └── ERD.md                  # entity relationship diagram (Mermaid)
├── docker-compose.yml
├── .env.example
└── LICENSE
```

## Quick start

```bash
cp .env.example .env
docker compose up -d
```

Docker automatically runs every file in `migrations/` on first boot
(via `docker-entrypoint-initdb.d`). To apply migrations against an existing
database instead:

```bash
export DATABASE_URL=postgresql://app_user:change_me@localhost:5432/generic_db
./scripts/init.sh
```

## What's included

| Table | Purpose |
|---|---|
| `users` | Core identity table (email, username, password hash, soft delete) |
| `roles` / `permissions` / `role_permissions` / `user_roles` | RBAC access control |
| `sessions` | Refresh tokens for auth sessions |
| `audit_log` | Automatic before/after snapshot of row changes (JSONB) |
| `attachments` | Polymorphic file table — attach a file to any row in any table |
| `notifications` | Per-user notification inbox |
| `app_settings` / `user_settings` | Global and per-user key/value config |

## Design choices

- **UUID primary keys** everywhere except small lookup tables (`roles`,
  `permissions`), which use `SMALLSERIAL` since they rarely grow.
- **Soft deletes** (`deleted_at`) on `users` and `attachments` instead of
  hard deletes, so history and audit trails stay intact.
- **`updated_at` auto-maintained** via trigger — never update it manually.
- **Audit trigger is opt-in per table** — `007_triggers_functions.sql`
  wires it onto `users` as an example; attach `audit_row_change()` to any
  other table the same way.
- **Polymorphic attachments** (`owner_table` + `owner_id`) avoid needing a
  new file table for every entity in the project.
- **`citext`** on email/username for case-insensitive uniqueness without
  manual `LOWER()` handling.

## Extending it

This is meant to be a foundation, not the final schema. Typical next step
for a real project: add domain tables (e.g. `orders`, `products`) that
reference `users.id`, and optionally attach the audit trigger to them too:

```sql
CREATE TRIGGER trg_orders_audit
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_row_change();
```

## License

MIT — see [LICENSE](./LICENSE).
