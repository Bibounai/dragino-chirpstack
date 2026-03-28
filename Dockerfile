FROM chirpstack/chirpstack:4 AS chirpstack-src

FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Copy ChirpStack binary and region configs from official image
COPY --from=chirpstack-src /usr/bin/chirpstack /usr/local/bin/chirpstack
COPY --from=chirpstack-src /etc/chirpstack/ /etc/chirpstack-defaults/

# Copy our config template
COPY chirpstack.toml.template /etc/chirpstack/chirpstack.toml.template
# Copy default region configs (eu868, etc.)
RUN cp /etc/chirpstack-defaults/region_*.toml /etc/chirpstack/ 2>/dev/null || true

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
