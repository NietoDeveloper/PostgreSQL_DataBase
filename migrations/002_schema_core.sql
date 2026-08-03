-- =====================================================================
-- 002_schema_core.sql
-- Core identity & access model: users, roles, permissions (RBAC).
-- Generic enough to be reused across projects.
-- =====================================================================

CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           CITEXT UNIQUE NOT NULL,
    username        CITEXT UNIQUE,
    password_hash   TEXT NOT NULL,
    full_name       TEXT,

);


