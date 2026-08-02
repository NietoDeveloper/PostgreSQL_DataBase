<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=0,2,2,5,30&height=240&section=header&text=POSTGRESQL%20DB&fontSize=80&fontColor=FFD700&fontAlignY=42&desc=⚡%20Functional%20Starter%20Schema%20·%20RBAC%20%2B%20Audit%20Trail%20·%20Docker%20Powered&descAlignY=62&descColor=DCDCDC&animation=fadeIn" width="100%"/>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Share+Tech+Mono&weight=700&size=20&duration=2800&pause=900&color=FFD700&center=true&vCenter=true&width=760&lines=%E2%9A%A1+Production-Grade+PostgreSQL+Foundation;%F0%9F%90%B3+Fully+Dockerized+%7C+Zero+Local+Dependencies;%F0%9F%94%92+Built-In+RBAC+%2B+Automatic+Audit+Trail;%F0%9F%93%A6+ORM-Agnostic+%7C+Plain+SQL+Migrations;%F0%9F%94%84+Polymorphic+Attachments+%7C+Soft+Deletes;%F0%9F%9A%80+Drop-In+Foundation+for+Any+New+Project;%F0%9F%8F%86+%231+GitHub+Committer+in+Colombia)](https://git.io/typing-svg)

<br/>

<p align="center">
  <a href="https://committers.top/colombia">
    <img src="https://img.shields.io/badge/🥇_No._1_Committer-Colombia-FFD700?style=for-the-badge&logoColor=000000"/>
  </a>
  <a href="https://committers.top">
    <img src="https://img.shields.io/badge/🏆_Top_3-South_%26_Central_America-DCDCDC?style=for-the-badge&logoColor=000000"/>
  </a>
  <img src="https://img.shields.io/badge/Status-Production_Ready-00D26A?style=for-the-badge&logo=checkmarx&logoColor=white"/>
  <img src="https://img.shields.io/badge/Security-Level_S%2B-FF0000?style=for-the-badge&logoColor=white"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white"/>
  <img src="https://img.shields.io/badge/PL%2FpgSQL-Triggers_%26_Functions-336791?style=for-the-badge&logo=postgresql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white"/>
  <img src="https://img.shields.io/badge/Auth-JWT_Ready-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=FFD700"/>
  <img src="https://img.shields.io/badge/RBAC-Roles_%26_Permissions-FFD700?style=for-the-badge&logoColor=000"/>
  <img src="https://img.shields.io/badge/Audit_Trail-JSONB-47A248?style=for-the-badge&logoColor=white"/>
  <img src="https://img.shields.io/badge/ORM-Agnostic-FF6B35?style=for-the-badge&logoColor=white"/>
</p>

<p align="center">
  <a href="https://github.com/NietoDeveloper/PostgreSQL_DataBase">
    <img src="https://img.shields.io/badge/📂_Source-NietoDeveloper%2FPostgreSQL__DataBase-000000?style=for-the-badge&logo=github&logoColor=FFD700"/>
  </a>
</p>

<br/>

> **Functional PostgreSQL Starter Database:** *The identity, access-control, and audit foundation meant to be dropped into any new project — MERN, Next.js, or otherwise.*

> 🐘 **PostgreSQL Functional Starter Schema.** A small, dependency-free, enterprise-grade foundation built with plain SQL migrations and PL/pgSQL, delivering authentication, role-based access control, automatic audit trails, polymorphic file attachments, notifications, and a settings store out of the box.
> State-of-the-art schema design for real-time auditability and reusable data orchestration across **any** Digital Twin, e-commerce, or SaaS ecosystem. A production-grade, ORM-agnostic foundation connecting new projects to a scalable, secure, Dockerized database — in minutes, not days.
>
> *Modular · Robust · Obsessively Production-Ready · Built in Bogotá 🇨🇴*

</div>

---

## 🆕 Latest Schema Updates

<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Share+Tech+Mono&weight=600&size=16&duration=3200&pause=1200&color=DCDCDC&center=true&vCenter=true&width=820&lines=%F0%9F%9B%A1%EF%B8%8F+Functional+RBAC%3A+Roles+%2B+Permissions+%2B+Sessions;%F0%9F%A7%BE+Automatic+Audit+Log+via+Reusable+PL%2FpgSQL+Trigger;%F0%9F%93%8E+Polymorphic+Attachments+%E2%80%94+Any+File%2C+Any+Table;%E2%99%BB%EF%B8%8F+Soft+Deletes+%2B+Auto-Maintained+updated_at" alt="Recent updates typing animation"/>

</div>

The initial release cycle of the Functional PostgreSQL Starter Database introduced the following architectural and infrastructure decisions:

| Update | Description | Impact |
|:-------|:-------------|:-------|
| 🔐 **Core Identity & RBAC** | `users`, `roles`, `permissions`, `role_permissions`, `user_roles`, and `sessions` tables — a complete, reusable auth foundation | Drop-in login/access-control layer for any new project, no rewrite needed |
| 🧾 **Functional Audit Trail** | Reusable `audit_row_change()` PL/pgSQL trigger function capturing before/after JSONB snapshots into `audit_log` | Full accountability on any table with a single `CREATE TRIGGER` statement |
| 📎 **Polymorphic Attachments** | `owner_table` + `owner_id` pattern lets any record in any table hold files without a dedicated join table | Faster iteration — no schema migration needed per new entity |
| ♻️ **Soft Deletes & Auto Timestamps** | `deleted_at` on sensitive tables, `updated_at` auto-maintained via trigger, never touched manually | History and audit integrity preserved by default |

---

## 🏗️ Schema Architecture

```
╔══════════════════════════════════════════════════════════════════════╗
║                  GENERIC POSTGRESQL STARTER SCHEMA                   ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                        ║
║   ┌─────────────────────┐       ┌──────────────────────────────┐     ║
║   │   IDENTITY CLUSTER   │      │        ACCESS CLUSTER          │     ║
║   │                     │       │                                │     ║
║   │  users              │◄─────►│  roles · permissions           │     ║
║   │  sessions           │       │  role_permissions · user_roles │     ║
║   └──────────┬──────────┘       └─────────────┬──────────────────┘     ║
║              │                                │                        ║
║              └──────────────┬─────────────────┘                        ║
║                             ▼                                          ║
║              ┌──────────────────────────────┐                          ║
║              │   PL/pgSQL Trigger Layer      │                         ║
║              │   set_updated_at()            │                         ║
║              │   audit_row_change()          │                         ║
║              └──────────────┬───────────────┘                          ║
║                             │                                          ║
║           ┌─────────────────┼─────────────────┐                        ║
║           ▼                 ▼                 ▼                        ║
║   ┌───────────────────┐ ┌───────────────────────┐ ┌───────────────┐    ║
║   │  audit_log         │ │  attachments            │ │  notifications │    ║
║   │  JSONB snapshots   │ │  Polymorphic file table │ │  user_settings │    ║
║   │  Full history      │ │  owner_table+owner_id   │ │  app_settings  │    ║
║   └───────────────────┘ └───────────────────────┘ └───────────────┘    ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

## 📂 Repository Structure

```text
PostgreSQL_DataBase/                ← Repo Root
│
├── 🗄️ migrations/                  ← Run in numeric order
│   ├── 001_extensions.sql          ← pgcrypto · citext · pg_trgm
│   ├── 002_schema_core.sql         ← users, roles, permissions, sessions
│   ├── 003_schema_audit.sql        ← audit_log
│   ├── 004_schema_files.sql        ← attachments
│   ├── 005_schema_notifications.sql
│   ├── 006_schema_settings.sql     ← app_settings, user_settings
│   ├── 007_triggers_functions.sql  ← PL/pgSQL trigger layer
│   └── 008_seed.sql                ← baseline roles & permissions
│
├── 🛠️ scripts/
│   ├── init.sh                     ← applies all migrations
│   └── reset.sh                    ← drops & re-applies everything (destructive)
│
├── 📖 docs/
│   └── ERD.md                      ← entity relationship diagram (Mermaid)
│
├── 🐳 docker-compose.yml           ← Master Orchestrator
├── ⚙️ .env.example
└── 📜 LICENSE
```

---

## 🛠️ Unified Technology Stack

<div align="center">

| Layer | Technologies | Engineering Focus |
|:------|:-------------|:------------------|
| 🐘 **Database Engine** | PostgreSQL 16 | ACID compliance · JSONB · Row-level triggers |
| 🧬 **Migrations** | Plain SQL, numeric-ordered | ORM-agnostic — Prisma, TypeORM, Sequelize, Knex, raw `pg` |
| ⚙️ **Logic Layer** | PL/pgSQL functions & triggers | Reusable audit + timestamp automation |
| 🔑 **Auth** | UUID identities · JWT-ready sessions | Multi-device refresh-token sessions |
| 🛡️ **Access Control** | RBAC (roles · permissions · mappings) | Fine-grained, per-endpoint authorization |
| 🧾 **Auditability** | JSONB before/after snapshots | Full accountability, opt-in per table |
| 📎 **Storage Pattern** | Polymorphic attachments | One table, any entity, any file |
| 🐳 **DevOps** | Docker Compose · Alpine-based Postgres image | Container-first · Zero local dependencies |

</div>

---

## ✨ Core Design Flows

### 🔄 Functional Audit Trail Pipeline

```mermaid
flowchart LR
    A([📝 Row Change]) -->|INSERT / UPDATE / DELETE| B[audit_row_change trigger]
    B -->|Reads session var| C{app.current_user_id}
    C -->|JSONB Snapshot| D[(audit_log)]
    D -->|Queryable History| E([👑 Compliance / Debugging])

    style A fill:#FFD700,color:#000,stroke:#FFD700
    style B fill:#000,color:#FFD700,stroke:#FFD700
    style D fill:#4169E1,color:#fff,stroke:#4169E1
    style E fill:#DCDCDC,color:#000,stroke:#DCDCDC
```

### 📎 Polymorphic Attachment Pipeline

```mermaid
flowchart LR
    A([📤 File Upload]) -->|owner_table + owner_id| B[attachments]
    B -->|Any Entity, No New Table| C{users / orders / anything}
    C --> D[(PostgreSQL)]
    D -->|Single Query Join| E([🖼️ Rendered Media])

    style A fill:#FFD700,color:#000,stroke:#FFD700
    style B fill:#4169E1,color:#fff,stroke:#4169E1
    style D fill:#000,color:#FFD700,stroke:#FFD700
    style E fill:#DCDCDC,color:#000,stroke:#DCDCDC
```

### 🔐 RBAC Authorization Flow

```mermaid
graph TD
    R([🔑 Auth Request]) --> V[Session / JWT Validation]
    V --> U[users.id]
    U --> UR[user_roles]
    UR --> RP[role_permissions]
    RP --> P{Permission Check}
    P -->|granted| OK[✅ Access Allowed]
    P -->|denied| X[403 · Access Denied]

    style R fill:#FFD700,color:#000
    style P fill:#0a0a0a,color:#FFD700,stroke:#FFD700
    style OK fill:#FFD700,color:#000
    style X fill:#FF0000,color:#fff
```

---

## 🗄️ What's Included

<div align="center">

| Table | Purpose |
|:------|:--------|
| `users` | Core identity table — email, username, password hash, soft delete |
| `roles` / `permissions` / `role_permissions` / `user_roles` | RBAC access control |
| `sessions` | Refresh tokens for authenticated sessions |
| `audit_log` | Automatic before/after snapshot of row changes (JSONB) |
| `attachments` | Polymorphic file table — attach a file to any row in any table |
| `notifications` | Per-user notification inbox |
| `app_settings` / `user_settings` | Global and per-user key/value configuration |

</div>

---

## 🐳 Docker Infrastructure Guide

> **Zero local dependencies.** Docker handles PostgreSQL, migrations, networking, and port binding — identical behavior from your laptop to production.

### Prerequisites

Install **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** and ensure the engine is running.

### ⚡ Quick Start — 2 Steps to a Ready Database

**Step 1 — Clone the repository**

```bash
git clone https://github.com/NietoDeveloper/PostgreSQL_DataBase.git
cd PostgreSQL_DataBase
cp .env.example .env
```

**Step 2 — Launch the master orchestrator**

```bash
docker compose up -d
```

```
🤖 What Docker does automatically:
   ├── Pulls postgres:16-alpine (lightweight, official image)
   ├── Creates the app_user role & functional_db database
   ├── Applies every file in migrations/ on first boot
   ├── Wires the PL/pgSQL trigger layer (audit + timestamps)
   └── Seeds baseline roles & permissions

   🐘  PostgreSQL  →  localhost:5432
```

To apply migrations against an **existing** database instead of a fresh
container:

```bash
export DATABASE_URL=postgresql://app_user:change_me@localhost:5432/functional_db
./scripts/init.sh
```

### 🛑 Operations & Maintenance

```bash
# Stop the database & release the port
docker compose down

# Full reset — DANGER: drops all data, re-applies every migration
./scripts/reset.sh

# View live logs
docker compose logs -f postgres

# Check running containers
docker ps

# Clean up unused images & volumes
docker system prune -f
```

---

## 🧩 Design Choices

- **UUID primary keys** everywhere except small lookup tables (`roles`,
  `permissions`), which use `SMALLSERIAL` since they rarely grow.
- **Soft deletes** (`deleted_at`) on `users` and `attachments` instead of
  hard deletes, so history and audit trails stay intact.
- **`updated_at` auto-maintained** via trigger — never update it manually.
- **Audit trigger is opt-in per table** — `007_triggers_functions.sql`
  wires it onto `users` as an example; attach `audit_row_change()` to any
  other table the same way.
- **Polymorphic attachments** (`owner_table` + `owner_id`) avoid needing a
  new file table for every entity in the project.
- **`citext`** on email/username for case-insensitive uniqueness without
  manual `LOWER()` handling.

---

## 🚀 Extending It

This is meant to be a foundation, not the final schema. Typical next step
for a real project: add domain tables (e.g. `orders`, `products`) that
reference `users.id`, and optionally attach the audit trigger to them too:

```sql
CREATE TRIGGER trg_orders_audit
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_row_change();
```

```
┌─────────────────────────────────────────────────────────┐
│                  TYPICAL ADOPTION PATH                   │
│                                                           │
│  git clone PostgreSQL_DataBase                            │
│       │                                                   │
│       ├──► docker compose up -d  → Ready in ~10s          │
│       │                                                   │
│       ├──► Add domain tables (orders, products, etc.)     │
│       │    referencing users.id                           │
│       │                                                   │
│       └──► Attach audit_row_change() where needed          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔗 Links & Resources

<div align="center">

| Resource | Link |
|:---------|:-----|
| 📂 **GitHub Repository** | [github.com/NietoDeveloper/PostgreSQL_DataBase](https://github.com/NietoDeveloper/PostgreSQL_DataBase) |
| 👤 **Developer Profile** | [github.com/NietoDeveloper](https://github.com/NietoDeveloper) |
| 🏆 **#1 Colombia Ranking** | [committers.top/colombia](https://committers.top/colombia) |
| 🌎 **Top LATAM Ranking** | [committers.top](https://committers.top) |
| 🐳 **Docker Desktop** | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |

</div>

---

<div align="center">

[![GitHub Profile](https://img.shields.io/badge/GitHub-NietoDeveloper-000?style=for-the-badge&logo=github&logoColor=FFD700)](https://github.com/NietoDeveloper)
[![#1 Colombia](https://img.shields.io/badge/🥇_%231_Committer-Colombia-FFD700?style=for-the-badge)](https://committers.top/colombia)
[![LATAM Top](https://img.shields.io/badge/🌎_Top_3-South_%26_Central_America-DCDCDC?style=for-the-badge)](https://committers.top)

<br/>

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   "Every schema is a foundation. Build it once,                  ║
║    reuse it everywhere, audit it always."                        ║
║                                                                  ║
║                               — NietoDeveloper Standard          ║
╚══════════════════════════════════════════════════════════════════╝
```

*PostgreSQL Functional Starter Database — Built by **NietoDeveloper · Manuel Nieto***

*Developed with technical rigor in* 📍 **Bogotá, Colombia** 🇨🇴

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=0,2,2,5,30&height=130&section=footer&animation=fadeIn" width="100%"/>

</div>
