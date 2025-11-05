FROM pretix/standalone:stable

USER root

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config" \
    PRETIX_URL=https://v1.tickets.kulturleben-berlin.de \
    PRETIX_INSTANCE_NAME="My Pretix Installation" \
    PRETIX_CURRENCY=EUR \
    PRETIX_TRUST_X_FORWARDED_FOR=on \
    PRETIX_TRUST_X_FORWARDED_PROTO=on

# Copy configuration file
COPY pretix.cfg /etc/pretix/pretix.cfg

# Cron functionality removed for Coolify compatibility

USER pretixuser

EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]