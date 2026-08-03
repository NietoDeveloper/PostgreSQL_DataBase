-- =====================================================================
-- 005_schema_notifications.sql
-- Functional per-user notification inbox.
-- =====================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    type        TEXT NOT NULL,             -- e.g. 'order.shipped', 'system.alert'
    title       TEXT NOT NULL,
    body        TEXT,
    metadata    JSONB NOT NULL DEFAULT '{}'::jsonb,
    read_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
    ON notifications (user_id) WHERE read_at IS NULL;
