-- =====================================================================
-- 003_schema_audit.sql
-- Functional audit trail. Captures who changed what, when, and how,
-- across ANY table in the database (via trigger, see 007).
-- =====================================================================

CREATE TABLE IF NOT EXISTS audit_log (
    id           BIGSERIAL PRIMARY KEY,
    table_name   TEXT NOT NULL,
    record_id    TEXT NOT NULL,
    action       TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data     JSONB,
    new_data     JSONB,
    changed_by   UUID REFERENCES users (id) ON DELETE SET NULL,
    changed_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_table_record ON audit_log (table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_changed_at    ON audit_log (changed_at);
