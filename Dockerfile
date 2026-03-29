FROM chirpstack/chirpstack:4 AS chirpstack-src
FROM chirpstack/chirpstack-gateway-bridge:4 AS gwbridge-src

FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    postgresql-client \
    mosquitto \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from official images
COPY --from=chirpstack-src /usr/bin/chirpstack /usr/local/bin/chirpstack
COPY --from=gwbridge-src /usr/bin/chirpstack-gateway-bridge /usr/local/bin/chirpstack-gateway-bridge

# Copy our config files
COPY chirpstack.toml.template /etc/chirpstack/chirpstack.toml.template
COPY gateway-bridge.toml /etc/chirpstack-gateway-bridge/gateway-bridge.toml
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
