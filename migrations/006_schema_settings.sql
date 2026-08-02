-- =====================================================================
-- 006_schema_settings.sql
-- Generic key/value configuration store — global app settings and
-- per-user preferences, without needing a new table per feature.
-- =====================================================================

CREATE TABLE IF NOT EXISTS app_settings (
    key         TEXT PRIMARY KEY,
    value       JSONB NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_settings (
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    key         TEXT NOT NULL,
    value       JSONB NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, key)
);
