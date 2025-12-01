-- ============================================================================
-- SQL Script de Inicialização para PostgreSQL - N8N
-- Executado automaticamente como superusuário 'postgres'
-- ============================================================================

-- ============================================================================
-- PARTE 1: BANCO DE DADOS INTERNO DO N8N (Configuração e Metadados)
-- ============================================================================

-- 1.1. Criar usuário 'n8n' se não existir
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = 'n8n'
   ) THEN
      CREATE USER n8n WITH PASSWORD 'n8n';
   END IF;
END
$$;

-- 1.2. Criar banco de dados 'n8n' (ignora erro se já existir)
CREATE DATABASE n8n OWNER n8n;

-- 1.3. Conceder privilégios no banco 'n8n'
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;

-- 1.4. Conectar ao banco 'n8n' e configurar privilégios do schema
\c n8n

-- 1.5. Conceder privilégios no schema public
GRANT ALL ON SCHEMA public TO n8n;
GRANT ALL ON ALL TABLES IN SCHEMA public TO n8n;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO n8n;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO n8n;

-- 1.6. Privilégios padrão para objetos futuros criados por n8n
ALTER DEFAULT PRIVILEGES FOR ROLE n8n IN SCHEMA public 
   GRANT ALL ON TABLES TO n8n;
ALTER DEFAULT PRIVILEGES FOR ROLE n8n IN SCHEMA public 
   GRANT ALL ON SEQUENCES TO n8n;
ALTER DEFAULT PRIVILEGES FOR ROLE n8n IN SCHEMA public 
   GRANT ALL ON FUNCTIONS TO n8n;

-- ============================================================================
-- PARTE 2: BANCO DE DADOS PARA WORKFLOWS (Dados de Aplicação)
-- ============================================================================

-- Voltar ao banco postgres para criar o próximo banco
\c postgres

-- 2.1. Criar usuário 'n8n_workflows' se não existir
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = 'n8n_workflows'
   ) THEN
      CREATE USER n8n_workflows WITH PASSWORD 'n8n';
   END IF;
END
$$;

-- 2.2. Criar banco de dados 'n8n_workflows' (ignora erro se já existir)
CREATE DATABASE n8n_workflows OWNER n8n_workflows;

-- 2.3. Conceder privilégios no banco 'n8n_workflows'
GRANT ALL PRIVILEGES ON DATABASE n8n_workflows TO n8n_workflows;

-- 2.4. Conectar ao banco 'n8n_workflows' e configurar privilégios
\c n8n_workflows

-- 2.5. Conceder privilégios no schema public
GRANT ALL ON SCHEMA public TO n8n_workflows;
GRANT ALL ON ALL TABLES IN SCHEMA public TO n8n_workflows;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO n8n_workflows;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO n8n_workflows;

-- 2.6. Privilégios padrão para objetos futuros
ALTER DEFAULT PRIVILEGES FOR ROLE n8n_workflows IN SCHEMA public 
   GRANT ALL ON TABLES TO n8n_workflows;
ALTER DEFAULT PRIVILEGES FOR ROLE n8n_workflows IN SCHEMA public 
   GRANT ALL ON SEQUENCES TO n8n_workflows;
ALTER DEFAULT PRIVILEGES FOR ROLE n8n_workflows IN SCHEMA public 
   GRANT ALL ON FUNCTIONS TO n8n_workflows;

-- ============================================================================
-- PARTE 3: EXTENSÕES ÚTEIS (Opcional)
-- ============================================================================

-- Criar extensões úteis no banco n8n_workflows
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- Geração de UUIDs
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Busca textual fuzzy
CREATE EXTENSION IF NOT EXISTS "btree_gin";      -- Índices GIN otimizados

-- Voltar ao banco postgres
\c postgres