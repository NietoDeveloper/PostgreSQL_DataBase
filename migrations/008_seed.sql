-- =====================================================================
-- 008_seed.sql
-- Minimal baseline data so the schema is usable out of the box.
-- =====================================================================

INSERT INTO roles (name, description) VALUES
    ('admin', 'Full system access'),
    ('user',  'Standard authenticated user')
ON CONFLICT (name) DO NOTHING;

INSERT INTO permissions (code, description) VALUES
    ('users.read',   'View users'),
    ('users.write',  'Create/update/delete users'),
    ('settings.read',  'View settings'),
    ('settings.write', 'Modify settings')
ON CONFLICT (code) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'user' AND p.code IN ('users.read', 'settings.read')
ON CONFLICT DO NOTHING;

INSERT INTO app_settings (key, value) VALUES
    ('app.name', '"My Functional App"'),
    ('app.maintenance_mode', 'false')
ON CONFLICT (key) DO NOTHING;
