#!/bin/bash
set -e

# Inject env vars into ChirpStack config
envsubst < /etc/chirpstack/chirpstack.toml.template > /etc/chirpstack/chirpstack.toml

# Inject $PORT into nginx config (only $PORT, leave nginx variables intact)
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Reset DB schema so ChirpStack migrations always run clean
echo "Resetting PostgreSQL schema..."
psql "${DATABASE_URL}" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" || true

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
