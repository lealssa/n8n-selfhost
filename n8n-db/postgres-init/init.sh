#!/bin/bash
# ============================================================================
# Script de Inicialização para PostgreSQL - N8N
# Executado automaticamente no docker-entrypoint-initdb.d
# ============================================================================

set -e

echo "🚀 Iniciando configuração do PostgreSQL para N8N..."

# ============================================================================
# PARTE 1: BANCO DE DADOS INTERNO DO N8N (Configuração e Metadados)
# ============================================================================

echo "📦 Criando usuário e banco de dados principal do N8N..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1.1. Criar usuário 'n8n' se não existir
    DO \$\$
    BEGIN
       IF NOT EXISTS (
          SELECT FROM pg_catalog.pg_roles
          WHERE rolname = '$N8N_DB_USER'
       ) THEN
          CREATE USER $N8N_DB_USER WITH PASSWORD '$N8N_DB_PASSWORD';
       END IF;
    END
    \$\$;

    -- 1.2. Criar banco de dados 'n8n' se não existir
    SELECT 'CREATE DATABASE $N8N_DB_NAME OWNER $N8N_DB_USER'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$N8N_DB_NAME')\gexec

    -- 1.3. Conceder privilégios no banco 'n8n'
    GRANT ALL PRIVILEGES ON DATABASE $N8N_DB_NAME TO $N8N_DB_USER;
EOSQL

echo "🔐 Configurando privilégios do schema no banco $N8N_DB_NAME..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$N8N_DB_NAME" <<-EOSQL
    -- 1.4. Conceder privilégios no schema public
    GRANT ALL ON SCHEMA public TO $N8N_DB_USER;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO $N8N_DB_USER;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $N8N_DB_USER;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO $N8N_DB_USER;

    -- 1.5. Privilégios padrão para objetos futuros
    ALTER DEFAULT PRIVILEGES FOR ROLE $N8N_DB_USER IN SCHEMA public 
       GRANT ALL ON TABLES TO $N8N_DB_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $N8N_DB_USER IN SCHEMA public 
       GRANT ALL ON SEQUENCES TO $N8N_DB_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $N8N_DB_USER IN SCHEMA public 
       GRANT ALL ON FUNCTIONS TO $N8N_DB_USER;
EOSQL

# ============================================================================
# PARTE 2: BANCO DE DADOS PARA WORKFLOWS (Dados de Aplicação)
# ============================================================================

echo "📦 Criando usuário e banco de dados para workflows..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 2.1. Criar usuário 'n8n_workflows' se não existir
    DO \$\$
    BEGIN
       IF NOT EXISTS (
          SELECT FROM pg_catalog.pg_roles
          WHERE rolname = '$N8N_WORKFLOWS_USER'
       ) THEN
          CREATE USER $N8N_WORKFLOWS_USER WITH PASSWORD '$N8N_WORKFLOWS_PASSWORD';
       END IF;
    END
    \$\$;

    -- 2.2. Criar banco de dados 'n8n_workflows' se não existir
    SELECT 'CREATE DATABASE $N8N_WORKFLOWS_DB OWNER $N8N_WORKFLOWS_USER'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$N8N_WORKFLOWS_DB')\gexec

    -- 2.3. Conceder privilégios no banco 'n8n_workflows'
    GRANT ALL PRIVILEGES ON DATABASE $N8N_WORKFLOWS_DB TO $N8N_WORKFLOWS_USER;
EOSQL

echo "🔐 Configurando privilégios do schema no banco $N8N_WORKFLOWS_DB..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$N8N_WORKFLOWS_DB" <<-EOSQL
    -- 2.4. Conceder privilégios no schema public
    GRANT ALL ON SCHEMA public TO $N8N_WORKFLOWS_USER;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO $N8N_WORKFLOWS_USER;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $N8N_WORKFLOWS_USER;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO $N8N_WORKFLOWS_USER;

    -- 2.5. Privilégios padrão para objetos futuros
    ALTER DEFAULT PRIVILEGES FOR ROLE $N8N_WORKFLOWS_USER IN SCHEMA public 
       GRANT ALL ON TABLES TO $N8N_WORKFLOWS_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $N8N_WORKFLOWS_USER IN SCHEMA public 
       GRANT ALL ON SEQUENCES TO $N8N_WORKFLOWS_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $N8N_WORKFLOWS_USER IN SCHEMA public 
       GRANT ALL ON FUNCTIONS TO $N8N_WORKFLOWS_USER;

    -- 2.6. Criar extensões úteis
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- Geração de UUIDs
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Busca textual fuzzy
    CREATE EXTENSION IF NOT EXISTS "btree_gin";      -- Índices GIN otimizados
EOSQL

echo "✅ Configuração do PostgreSQL concluída com sucesso!"
echo "   - Usuário N8N: $N8N_DB_USER"
echo "   - Banco N8N: $N8N_DB_NAME"
echo "   - Usuário Workflows: $N8N_WORKFLOWS_USER"
echo "   - Banco Workflows: $N8N_WORKFLOWS_DB"