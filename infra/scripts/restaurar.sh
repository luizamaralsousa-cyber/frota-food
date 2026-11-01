#!/usr/bin/env bash
# Uso: pnpm db:restaurar infra/dev/snapshots/<arquivo>.dump
set -euo pipefail
ARQ="${1:?informe o arquivo .dump}"
URL=postgresql://frota_owner:dev_owner@localhost:5432/frotafood_dev
psql "$URL" -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS drizzle CASCADE;"
pg_restore -d "$URL" --clean --if-exists --no-owner --role=frota_owner "$ARQ"
echo "Restaurado: $ARQ"
