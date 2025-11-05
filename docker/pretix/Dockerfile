FROM pretix/standalone:stable

USER root

ENV IMAGE_CRON_DIR="/image/cron" \
    IMAGE_CONFIG_DIR="/image/config"

ADD files /image
COPY crontab /tmp/crontab

RUN mv /image/supervisord/crond.conf /etc/supervisord/crond.conf && \
    pip install crontab && chmod +x $IMAGE_CRON_DIR/cron.py

USER pretixuser

EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]