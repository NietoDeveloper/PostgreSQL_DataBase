-- =====================================================================
-- 002_schema_core.sql
-- Core identity & access model: users, roles, permissions (RBAC).
-- Hardened: format/length constraints, brute-force lockout fields,
-- hashed session tokens (never store raw tokens at rest).
-- =====================================================================

CREATE TABLE IF NOT EXISTS users (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email                 CITEXT UNIQUE NOT NULL,
    username              CITEXT UNIQUE,
    password_hash         TEXT NOT NULL,
    full_name             TEXT,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified           BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_attempts SMALLINT NOT NULL DEFAULT 0,
    locked_until          TIMESTAMPTZ,
    last_login_at         TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at            TIMESTAMPTZ,

    -- Basic shape validation at the data layer (defense in depth —
    -- do not rely on this instead of application-level validation).
    CONSTRAINT chk_users_email_format
        CHECK (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    CONSTRAINT chk_users_username_len
        CHECK (username IS NULL OR char_length(username) BETWEEN 3 AND 32),
    -- Rejects empty/placeholder hashes; does not validate the hashing
    -- algorithm itself (enforce bcrypt/argon2 in the application layer).
    CONSTRAINT chk_users_password_hash_not_blank
        CHECK (char_length(password_hash) >= 20)
);

CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users (deleted_at);
CREATE INDEX IF NOT EXISTS idx_users_is_active   ON users (is_active) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS roles (
    id          SMALLSERIAL PRIMARY KEY,
    name        CITEXT UNIQUE NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS permissions (
    id          SMALLSERIAL PRIMARY KEY,
    code        CITEXT UNIQUE NOT NULL,   -- e.g. 'users.read', 'orders.write'
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id       SMALLINT NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    permission_id SMALLINT NOT NULL REFERENCES permissions (id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID     NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_id SMALLINT NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Auth sessions. The raw refresh token is NEVER stored — only a SHA-256
-- hash of it (computed at the application layer). A leaked database
-- backup therefore does not leak usable session tokens.
CREATE TABLE IF NOT EXISTS sessions (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    refresh_token_hash TEXT NOT NULL UNIQUE,
    user_agent         TEXT,
    ip_address         INET,
    expires_at         TIMESTAMPTZ NOT NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at         TIMESTAMPTZ,

    CONSTRAINT chk_sessions_token_hash_len
        CHECK (char_length(refresh_token_hash) >= 40)
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions (expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_active
    ON sessions (user_id) WHERE revoked_at IS NULL;
