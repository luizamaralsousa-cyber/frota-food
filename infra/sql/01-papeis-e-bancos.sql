-- Frota Food - papéis e bancos de desenvolvimento (senhas só do notebook)
CREATE ROLE frota_owner LOGIN PASSWORD 'dev_owner';                 -- dono das tabelas (migrações)
CREATE ROLE frota_app   LOGIN PASSWORD 'dev_app' NOBYPASSRLS;       -- API e workers (sujeito ao RLS)
ALTER ROLE frota_app SET statement_timeout = '5s';
ALTER ROLE frota_app SET idle_in_transaction_session_timeout = '30s';
CREATE ROLE evolution   LOGIN PASSWORD 'dev_evo' CONNECTION LIMIT 10;

CREATE DATABASE frotafood_dev   OWNER frota_owner;
CREATE DATABASE frotafood_teste OWNER frota_owner;                  -- testes automatizados
CREATE DATABASE evolution       OWNER evolution;

REVOKE CONNECT ON DATABASE frotafood_dev, frotafood_teste, evolution FROM PUBLIC;
GRANT  CONNECT ON DATABASE frotafood_dev, frotafood_teste TO frota_app;
