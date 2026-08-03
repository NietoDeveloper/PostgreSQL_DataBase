-- =====================================================================
-- 001_extensions.sql
-- Required PostgreSQL extensions.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid(), hashing
CREATE EXTENSION IF NOT EXISTS "citext";     -- case-insensitive text (emails)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- fuzzy / partial text search
