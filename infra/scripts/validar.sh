#!/usr/bin/env bash
# Frota Food - valida a stack nativa da workstation. Uso: pnpm stack:validar
set -uo pipefail
URL_DONO="postgresql://frota_owner:dev_owner@localhost:5432/frotafood_dev"
URL_APP="postgresql://frota_app:dev_app@localhost:6432/frotafood_dev"
RED="redis-cli -a dev_redis --no-auth-warning"
FALHAS=0
ok()    { printf '  \033[32mOK\033[0m    %s\n' "$1"; }
falha() { printf '  \033[31mFALHA\033[0m %s\n' "$1"; FALHAS=$((FALHAS + 1)); }
sql()   { psql "$URL_DONO" -Atqc "$1" 2>/dev/null; }
se()    { if [ "$2" = "$3" ]; then ok "$1"; else falha "$1 (obtido: '$2')"; fi; }

echo "Serviços"
for s in postgresql@16-main pgbouncer redis-server docker; do se "$s ativo" "$(systemctl is-active $s)" active; done
se "frota-evolution rodando" "$(docker inspect -f '{{.State.Status}}' frota-evolution 2>/dev/null)" running

echo "PostgreSQL"
se "shared_buffers igual à VPS" "$(sql 'SHOW shared_buffers')" 4GB
for e in postgis citext pg_trgm unaccent btree_gin pg_stat_statements; do
  se "extensão $e" "$(sql "SELECT count(*) FROM pg_extension WHERE extname = '$e'")" 1
done
se "UUIDv7 versão 7" "$(sql 'SELECT substr(uuid_generate_v7()::text, 15, 1)')" 7
se "UUIDv7 com horário atual" "$(sql 'SELECT abs(extract(epoch FROM uuid_v7_horario(uuid_generate_v7()) - now())) < 5')" t
se "frota_app via PgBouncer (6432)" "$(psql "$URL_APP" -Atqc 'SELECT current_user' 2>/dev/null)" frota_app
se "frota_app NÃO ignora RLS" "$(psql "$URL_APP" -Atqc 'SELECT rolbypassrls FROM pg_roles WHERE rolname = current_user' 2>/dev/null)" f
se "banco de testes existe" "$(sql "SELECT count(*) FROM pg_database WHERE datname = 'frotafood_teste'")" 1

echo "Redis e Evolution"
se "Redis PING com senha" "$($RED PING 2>/dev/null)" PONG
se "Redis 7.4" "$($RED INFO server 2>/dev/null | awk -F: '/^redis_version/ {print substr($2,1,3)}' | tr -d '\r')" 7.4
se "Redis noeviction" "$($RED CONFIG GET maxmemory-policy 2>/dev/null | tail -1)" noeviction
if curl -fsS http://localhost:8080 >/dev/null 2>&1; then ok "Evolution API (8080)"; else falha "Evolution API (8080)"; fi

echo "Exposição de rede (nada fora de 127.0.0.1)"
EXPOSTOS=$(ss -tlnH | awk '{print $4}' | grep -E ':(5432|6432|6379|8080)$' | grep -vE '^(127\.0\.0\.1|\[::1\]|172\.17\.0\.1):' || true)
se "portas da stack só locais" "${EXPOSTOS:-nenhuma}" nenhuma

echo
if [ "$FALHAS" -eq 0 ]; then echo "Stack pronta para a Parte 2."; else echo "$FALHAS verificação(ões) falharam."; exit 1; fi
