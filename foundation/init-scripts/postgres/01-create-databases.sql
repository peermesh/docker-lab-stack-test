-- ==============================================================
-- PostgreSQL Database Initialization
-- ==============================================================
-- Creates databases and users for all applications that use PostgreSQL
-- Executed on first container startup
-- ==============================================================

-- PeerTube database
CREATE DATABASE peertube;
CREATE USER peertube WITH ENCRYPTED PASSWORD 'peertube_password_replace_me';
GRANT ALL PRIVILEGES ON DATABASE peertube TO peertube;

-- Listmonk database
CREATE DATABASE listmonk;
CREATE USER listmonk WITH ENCRYPTED PASSWORD 'listmonk_password_replace_me';
GRANT ALL PRIVILEGES ON DATABASE listmonk TO listmonk;

-- n8n database
CREATE DATABASE n8n;
CREATE USER n8n WITH ENCRYPTED PASSWORD 'n8n_password_replace_me';
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;

-- Manyfold database
CREATE DATABASE manyfold;
CREATE USER manyfold WITH ENCRYPTED PASSWORD 'manyfold_password_replace_me';
GRANT ALL PRIVILEGES ON DATABASE manyfold TO manyfold;

-- Enable pgvector extension for all databases that might need it
\c peertube
CREATE EXTENSION IF NOT EXISTS vector;

\c listmonk
CREATE EXTENSION IF NOT EXISTS vector;

\c n8n
CREATE EXTENSION IF NOT EXISTS vector;

\c manyfold
CREATE EXTENSION IF NOT EXISTS vector;
