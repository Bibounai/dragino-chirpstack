#!/bin/bash
set -e

# Inject env vars into ChirpStack config
envsubst < /etc/chirpstack/chirpstack.toml.template > /etc/chirpstack/chirpstack.toml

# Inject $PORT into nginx config (only $PORT, leave nginx variables intact)
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Extract DB user from DATABASE_URL
DB_USER=$(echo "${DATABASE_URL}" | sed 's|postgresql://\([^:]*\):.*|\1|')

# Reset DB schema, restore privileges, and pre-create extensions
echo "Resetting PostgreSQL schema and creating extensions..."
psql "${DATABASE_URL}" <<EOSQL || true
  DROP SCHEMA public CASCADE;
  CREATE SCHEMA public;
  GRANT ALL ON SCHEMA public TO ${DB_USER};
  GRANT ALL ON SCHEMA public TO public;
  CREATE EXTENSION IF NOT EXISTS hstore;
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOSQL

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
