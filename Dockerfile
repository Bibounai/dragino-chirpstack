FROM chirpstack/chirpstack:4

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY chirpstack.toml.template /etc/chirpstack/chirpstack.toml.template
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
