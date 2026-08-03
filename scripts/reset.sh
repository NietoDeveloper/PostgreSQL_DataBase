#!/usr/bin/env bash
# DANGER: drops the public schema and re-applies all migrations from scratch.
set -euo pipefail

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is not set. Export it or source your .env file first."
  exit 1
fi

read -p "This will DROP all data. Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
  echo "Aborted."
  exit 0
fi
