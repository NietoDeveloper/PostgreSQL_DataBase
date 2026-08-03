-- =====================================================================
-- 004_schema_files.sql
-- Generic polymorphic attachments table — link a file (stored in S3,
-- local disk, etc.) to any record in any table.
-- =====================================================================

CREATE TABLE IF NOT EXISTS attachments (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_table   TEXT NOT NULL,          -- e.g. 'users', 'orders'
    owner_id      TEXT NOT NULL,          -- polymorphic FK (cast as needed)
  url      TEXT NOT NULL,
