-- =====================================================================
-- 004_schema_files.sql
-- Generic polymorphic attachments table — link a file (stored in S3,
-- local disk, etc.) to any record in any table.
-- =====================================================================

CREATE TABLE IF NOT EXISTS attachments (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_table   TEXT NOT NULL,          -- e.g. 'users', 'orders'
    owner_id      TEXT NOT NULL,          -- polymorphic FK (cast as needed)
    file_name     TEXT NOT NULL,
    file_url      TEXT NOT NULL,
    mime_type     TEXT,
    size_bytes    BIGINT,
    uploaded_by   UUID REFERENCES users (id) ON DELETE SET NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_attachments_owner ON attachments (owner_table, owner_id);
