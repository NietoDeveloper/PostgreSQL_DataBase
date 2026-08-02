# Entity Relationship Diagram

```mermaid
erDiagram
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : assigned_to
    ROLES ||--o{ ROLE_PERMISSIONS : has
    PERMISSIONS ||--o{ ROLE_PERMISSIONS : granted_via
    USERS ||--o{ SESSIONS : opens
    USERS ||--o{ NOTIFICATIONS : receives
    USERS ||--o{ USER_SETTINGS : configures
    USERS ||--o{ ATTACHMENTS : uploads
    USERS ||--o{ AUDIT_LOG : triggers

    USERS {
        uuid id PK
        citext email
        citext username
        text password_hash
        boolean is_active
        boolean is_verified
        timestamptz deleted_at
    }

    ROLES {
        smallserial id PK
        citext name
    }

    PERMISSIONS {
        smallserial id PK
        citext code
    }

    SESSIONS {
        uuid id PK
        uuid user_id FK
        text refresh_token
        timestamptz expires_at
    }

    ATTACHMENTS {
        uuid id PK
        text owner_table
        text owner_id
        text file_url
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        text type
        jsonb metadata
    }

    AUDIT_LOG {
        bigserial id PK
        text table_name
        text record_id
        text action
        jsonb old_data
        jsonb new_data
    }

    APP_SETTINGS {
        text key PK
        jsonb value
    }

    USER_SETTINGS {
        uuid user_id FK
        text key
        jsonb value
    }
```

`ATTACHMENTS` uses a polymorphic pattern (`owner_table` + `owner_id`) so it can
attach a file to a row in **any** table without a dedicated foreign key per
entity — this is what makes the schema reusable across projects.



















# Entity Relationship Diagram

```mermaid
erDiagram
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : assigned_to
    ROLES ||--o{ ROLE_PERMISSIONS : has
    PERMISSIONS ||--o{ ROLE_PERMISSIONS : granted_via
    USERS ||--o{ SESSIONS : opens
    USERS ||--o{ NOTIFICATIONS : receives
    USERS ||--o{ configures
    USERS ||--o{ ATTACHMENTS : uploads
    USERS ||--o{ AUDIT_LOG :
    USERS {
        uuid id PK
        citext email
        citext username
        text password_hash
        boolean is_active
        boolean is_verified
        timestamptz deleted_at
    }

