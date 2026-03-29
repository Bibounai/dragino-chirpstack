#!/bin/bash
set -e

# Inject env vars into ChirpStack config
envsubst < /etc/chirpstack/chirpstack.toml.template > /etc/chirpstack/chirpstack.toml

# Remove the template so ChirpStack only loads the valid .toml file
rm /etc/chirpstack/chirpstack.toml.template

# Inject $PORT into nginx config (only $PORT, leave nginx variables intact)
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Create required directories for Mosquitto
mkdir -p /run/mosquitto
chown mosquitto:mosquitto /run/mosquitto

# Create extensions if they don't exist (no schema reset)
echo "Ensuring PostgreSQL extensions exist..."
psql "${DATABASE_URL}" <<EOSQL || true
  CREATE EXTENSION IF NOT EXISTS hstore;
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOSQL

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
