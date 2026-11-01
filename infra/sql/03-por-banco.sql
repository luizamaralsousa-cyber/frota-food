CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- UUIDv7: UUID v4 com os 48 primeiros bits trocados pelo horário Unix em ms e
-- o nibble de versão ajustado de 0100 (4) para 0111 (7). Ordenável por tempo.
CREATE OR REPLACE FUNCTION public.uuid_generate_v7() RETURNS uuid
LANGUAGE sql VOLATILE PARALLEL SAFE AS $$
  SELECT encode(
    set_bit(set_bit(
      overlay(uuid_send(gen_random_uuid())
              PLACING substring(int8send(floor(extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 3)
              FROM 1 FOR 6),
      52, 1), 53, 1),
    'hex')::uuid;
$$;

-- Horário embutido num UUIDv7 (auditoria e testes)
CREATE OR REPLACE FUNCTION public.uuid_v7_horario(u uuid) RETURNS timestamptz
LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS $$
  SELECT to_timestamp(('x' || substr(replace(u::text, '-', ''), 1, 12))::bit(48)::bigint / 1000.0);
$$;

GRANT USAGE ON SCHEMA public TO frota_app;
ALTER DEFAULT PRIVILEGES FOR ROLE frota_owner IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO frota_app;
ALTER DEFAULT PRIVILEGES FOR ROLE frota_owner IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO frota_app;
