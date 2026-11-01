-- Frota Food - extensões e UUIDv7 (superusuário). Versão de um comando, usada na VPS.
\set ON_ERROR_STOP on
\connect frotafood_dev
\ir 03-por-banco.sql
\connect frotafood_teste
\ir 03-por-banco.sql
