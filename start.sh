#!/bin/bash
set -e

# Inject env vars into ChirpStack config
envsubst < /etc/chirpstack/chirpstack.toml.template > /etc/chirpstack/chirpstack.toml

# Inject $PORT into nginx config (only $PORT, leave nginx variables intact)
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
