FROM pretix/standalone:stable

USER root

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config"

ADD files /image
# Ensure the image contains the crontab file where the runtime expects it
# so that bind-mounting or external tooling doesn't turn the path into a
# directory. Place the file under the image cron dir used at runtime.
COPY crontab /image/cron/crontab
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh || true
# Ensure crontab is owned by the runtime user so the cron runner can read it
RUN chown pretixuser:pretixuser /image/cron/crontab || true

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
# Ensure the runtime config directory is writable by the runtime user so
# the entrypoint (which runs as that user) can render a config file there.
RUN chown -R pretixuser:pretixuser /image/config /etc/pretix || true

RUN mv /image/supervisord/crond.conf /etc/supervisord/crond.conf && \
    pip install crontab && chmod 644 $IMAGE_CONFIG_DIR/ssl/*.crt && chmod +x $IMAGE_CRON_DIR/cron.py

USER pretixuser

# Expose HTTP only; Coolify/Traefik will terminate TLS
EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["all"]