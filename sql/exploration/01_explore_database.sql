-- Encontrar todos os schemas no banco de dados
SELECT schema_name
FROM information_schema.schemata;

-- Encontrar todas as tabelas e views em todos os schemas
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
