-- =====================================================================
-- 009_security_hardening.sql
-- Defense-in-depth layer: least-privilege roles, row-level security,
-- an append-only audit log, and sane per-connection limits.
--
-- Run this AFTER 001-008. It assumes the connecting role that runs
-- migrations is a superuser/owner (e.g. the Docker POSTGRES_USER) —
-- the roles created here are for the APPLICATION to use instead.
-- =====================================================================

-- 1) Least-privilege group roles. Applications should never connect
--    as the migration/owner role.
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_rw') THEN
        CREATE ROLE app_rw NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_ro') THEN
        CREATE ROLE app_ro NOLOGIN;
    END IF;
END $$;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO app_rw, app_ro;

GRANT SELECT, INSERT, UPDATE, DELETE ON
    users, roles, permissions, role_permissions, user_roles, sessions,
    attachments, notifications, app_settings, user_settings
    TO app_rw;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_ro;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_ro;

-- audit_log is append-only: no role (including app_rw) may UPDATE or
-- DELETE rows in it — writes only happen through the audit trigger.
GRANT SELECT, INSERT ON audit_log TO app_rw;
REVOKE UPDATE, DELETE, TRUNCATE ON audit_log FROM app_rw, app_ro, PUBLIC;

-- 2) Row-Level Security — each user can only see/modify their own row
--    unless the connection has explicitly set app.is_admin = 'true'
--    (service-role / backoffice operations only, never the default).
ALTER TABLE users           ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications   ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings   ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_self_access ON users;
CREATE POLICY users_self_access ON users
    USING (
        id = NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID
        OR current_setting('app.is_admin', TRUE) = 'true'
    );

DROP POLICY IF EXISTS sessions_self_access ON sessions;
CREATE POLICY sessions_self_access ON sessions
    USING (
        user_id = NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID
        OR current_setting('app.is_admin', TRUE) = 'true'
    );

DROP POLICY IF EXISTS notifications_self_access ON notifications;
CREATE POLICY notifications_self_access ON notifications
    USING (
        user_id = NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID
        OR current_setting('app.is_admin', TRUE) = 'true'
    );

DROP POLICY IF EXISTS user_settings_self_access ON user_settings;
CREATE POLICY user_settings_self_access ON user_settings
    USING (
        user_id = NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID
        OR current_setting('app.is_admin', TRUE) = 'true'
    );

-- 3) Sane per-role connection defaults — bound how long a bad query or
--    an abandoned transaction can hold locks/resources.
ALTER ROLE app_rw SET statement_timeout = '30s';
ALTER ROLE app_rw SET idle_in_transaction_session_timeout = '60s';
ALTER ROLE app_ro SET statement_timeout = '15s';
ALTER ROLE app_ro SET idle_in_transaction_session_timeout = '30s';

-- 4) Lock down the brute-force helper functions and audit trigger
--    function to the write role only.
REVOKE ALL ON FUNCTION register_failed_login(UUID, SMALLINT, INTERVAL) FROM PUBLIC;
REVOKE ALL ON FUNCTION register_successful_login(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION is_account_locked(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION register_failed_login(UUID, SMALLINT, INTERVAL) TO app_rw;
GRANT EXECUTE ON FUNCTION register_successful_login(UUID) TO app_rw;
GRANT EXECUTE ON FUNCTION is_account_locked(UUID) TO app_rw, app_ro;
