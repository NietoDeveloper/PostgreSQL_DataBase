-- =====================================================================
-- 007_triggers_functions.sql
-- Reusable functions + triggers wired onto the tables above.
-- =====================================================================

-- 1) Auto-maintain updated_at on any table that has the column.
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_app_settings_updated_at
    BEFORE UPDATE ON app_settings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2) Generic audit trigger — attach to any table to log INSERT/UPDATE/DELETE
--    into audit_log automatically. Reads the app.current_user_id session
--    variable if the application sets it (SET LOCAL app.current_user_id = '...').
CREATE OR REPLACE FUNCTION audit_row_change()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Wire the audit trigger onto the tables that matter most.
-- Add/remove `CREATE TRIGGER` blocks per table as your project needs.
CREATE TRIGGER trg_users_audit
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_row_change();

-- 3) Soft-delete helper — call instead of DELETE to preserve history.
CREATE OR REPLACE FUNCTION soft_delete_user(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users SET deleted_at = now() WHERE id = p_user_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;
