#!/usr/bin/env bash
# Runs every migration in /migrations, in filename order, against $DATABASE_URL.
set -euo pipefail

if [ -z "${DATABASE_URL:-}" ]; then
