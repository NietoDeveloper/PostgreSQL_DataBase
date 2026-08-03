-- =====================================================================
-- 007_triggers_functions.sql
-- Reusable functions + triggers wired onto the tables above.
-- Hardened: every function pins search_path (prevents search_path
-- hijacking against SECURITY DEFINER functions) and uses explicit
-- schema-qualified references where it matters.
-- =====================================================================

-- 1) Auto-maintain updated_at on any table that has the column.
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_app_settings_updated_at
    BEFORE UPDATE ON app_settings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2) Functional audit trigger — attach to any table to log INSERT/UPDATE/DELETE
--    into audit_log automatically. Reads the app.current_user_id session
--    variable if the application sets it (SET LOCAL app.current_user_id = '...').
--    SECURITY DEFINER + fixed search_path so a lower-privileged caller
--    can't redirect it to a spoofed audit_log via a crafted search_path.
CREATE OR REPLACE FUNCTION audit_row_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    BEGIN
        v_user_id := NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;
    EXCEPTION WHEN OTHERS THEN
        v_user_id := NULL;
    END;

    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data, changed_by)
        VALUES (TG_TABLE_NAME, OLD.id::TEXT, 'DELETE', to_jsonb(OLD), v_user_id);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id::TEXT, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), v_user_id);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (table_name, record_id, action, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id::TEXT, 'INSERT', to_jsonb(NEW), v_user_id);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$;

REVOKE ALL ON FUNCTION audit_row_change() FROM PUBLIC;

-- Wire the audit trigger onto the tables that matter most.
-- Add/remove `CREATE TRIGGER` blocks per table as your project needs.
CREATE TRIGGER trg_users_audit
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_row_change();

-- 3) Soft-delete helper — call instead of DELETE to preserve history.
CREATE OR REPLACE FUNCTION soft_delete_user(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE users SET deleted_at = now() WHERE id = p_user_id AND deleted_at IS NULL;
END;
$$;

-- 4) Brute-force protection helpers. The application calls these instead
--    of writing to failed_login_attempts / locked_until directly, so the
--    lockout policy lives in one place.
CREATE OR REPLACE FUNCTION register_failed_login(
    p_user_id UUID,
    p_max_attempts SMALLINT DEFAULT 5,
    p_lock_duration INTERVAL DEFAULT '15 minutes'
)
RETURNS VOID
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE users
    SET failed_login_attempts = failed_login_attempts + 1,
        locked_until = CASE
            WHEN failed_login_attempts + 1 >= p_max_attempts
                THEN now() + p_lock_duration
            ELSE locked_until
        END
    WHERE id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION register_successful_login(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE users
    SET failed_login_attempts = 0,
        locked_until = NULL,
        last_login_at = now()
    WHERE id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION is_account_locked(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
    SELECT locked_until IS NOT NULL AND locked_until > now()
    FROM users WHERE id = p_user_id;
$$;
