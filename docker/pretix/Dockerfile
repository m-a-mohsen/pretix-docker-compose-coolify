FROM pretix/standalone:stable

USER root

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config"

ADD files /image
COPY crontab /tmp/crontab

# Copy our baked nginx configuration into the image so we don't need a host bind-mount
# The build context is `./docker/pretix`, so this copies `docker/pretix/nginx/nginx.conf` -> `/etc/nginx/nginx.conf`
COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN mv /image/supervisord/crond.conf /etc/supervisord/crond.conf && \
    pip install crontab && chmod 644 $IMAGE_CONFIG_DIR/ssl/*.crt && chmod +x $IMAGE_CRON_DIR/cron.py

USER pretixuser

# Expose HTTP only; Coolify/Traefik will terminate TLS
EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]