FROM chirpstack/chirpstack:4 AS chirpstack-src

FROM debian:12-slim

# Install base packages + Mosquitto from official repo (for MQTT v5 support)
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    postgresql-client \
    wget \
    gnupg \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/mosquitto.asc https://repo.mosquitto.org/debian/mosquitto-repo.gpg.key \
    && echo "deb [signed-by=/etc/apt/keyrings/mosquitto.asc] https://repo.mosquitto.org/debian bookworm main" > /etc/apt/sources.list.d/mosquitto.list \
    && apt-get update && apt-get install -y mosquitto \
    && rm -rf /var/lib/apt/lists/*

# Copy ChirpStack binary from official image
COPY --from=chirpstack-src /usr/bin/chirpstack /usr/local/bin/chirpstack

# Copy our config files
COPY chirpstack.toml.template /etc/chirpstack/chirpstack.toml.template
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
