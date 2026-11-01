#!/usr/bin/env bash
# Uso: pnpm db:snapshot [nome]
set -euo pipefail
cd "$(dirname "$0")/../.."
ARQ="infra/dev/snapshots/frotafood_dev-$(date +%F_%H%M)-${1:-manual}.dump"
pg_dump postgresql://frota_owner:dev_owner@localhost:5432/frotafood_dev -Fc -Z 6 -f "$ARQ"
echo "Fotografia salva: $ARQ"
