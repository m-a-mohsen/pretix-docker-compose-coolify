FROM pretix/standalone:stable

USER root

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config"

ADD files /image
COPY crontab /tmp/crontab

# Copy our baked nginx configuration into the image so we don't need a host bind-mount
# The build context is `./docker/pretix`, so this copies `docker/pretix/nginx/nginx.conf` -> `/etc/nginx/nginx.conf`
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Provide a default pretix configuration inside the image so Pretix has a valid
# locale and other settings even when no host mount is provided by Coolify.
# This avoids the "Default language  is not one of the available" error.
COPY pretix.cfg /etc/pretix/pretix.cfg
# Also copy into the image config directory used by the container runtime
# so Pretix's config loader (which references $IMAGE_CONFIG_DIR) finds it.
COPY pretix.cfg /image/config/pretix.cfg

RUN mv /image/supervisord/crond.conf /etc/supervisord/crond.conf && \
    pip install crontab && chmod 644 $IMAGE_CONFIG_DIR/ssl/*.crt && chmod +x $IMAGE_CRON_DIR/cron.py

USER pretixuser

# Expose HTTP only; Coolify/Traefik will terminate TLS
EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]