#!/bin/bash
set -e

# Inject env vars into ChirpStack config
envsubst < /etc/chirpstack/chirpstack.toml.template > /etc/chirpstack/chirpstack.toml

# Inject $PORT into nginx config (only $PORT, leave nginx variables intact)
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Extract DB user from DATABASE_URL (format: postgresql://user:pass@host/db)
DB_USER=$(echo "${DATABASE_URL}" | sed 's|postgresql://\([^:]*\):.*|\1|')

# Reset DB schema and restore privileges so ChirpStack migrations can run
echo "Resetting PostgreSQL schema..."
psql "${DATABASE_URL}" -c "
  DROP SCHEMA public CASCADE;
  CREATE SCHEMA public;
  GRANT ALL ON SCHEMA public TO ${DB_USER};
  GRANT ALL ON SCHEMA public TO public;
" || true

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
