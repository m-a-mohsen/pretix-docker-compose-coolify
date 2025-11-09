FROM pretix/standalone:stable

USER root

# Optionally install plugins during image build. Pass a space-separated list
# via --build-arg PRETIX_PLUGINS="plugin1 plugin2" when building.
ARG PRETIX_PLUGINS=""
RUN if [ -n "$PRETIX_PLUGINS" ]; then \
    pip3 install $PRETIX_PLUGINS; \
    fi

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config"

ADD files /image
COPY crontab /tmp/crontab
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh || true

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

# If plugins were installed, compile production assets inside the source tree.
# This step is only executed when PRETIX_PLUGINS was provided at build time.
RUN if [ -n "$PRETIX_PLUGINS" ]; then \
    cd /pretix/src && make production; \
    fi
# Expose HTTP only; Coolify/Traefik will terminate TLS
EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["all"]