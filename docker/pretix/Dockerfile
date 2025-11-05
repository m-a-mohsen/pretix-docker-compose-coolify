FROM pretix/standalone:stable

USER root

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config"




# Cron functionality removed for Coolify compatibility

USER pretixuser

EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]