FROM pretix/standalone:stable

# Create a simple startup script to set configuration
RUN echo '[pretix]' > /etc/pretix/pretix.cfg && \
    echo 'instance_name=My Pretix Installation' >> /etc/pretix/pretix.cfg && \
    echo 'url=https://v1.tickets.kulturleben-berlin.de' >> /etc/pretix/pretix.cfg && \
    echo 'currency=EUR' >> /etc/pretix/pretix.cfg && \
    echo 'datadir=/data' >> /etc/pretix/pretix.cfg && \
    echo 'trust_x_forwarded_for=on' >> /etc/pretix/pretix.cfg && \
    echo 'trust_x_forwarded_proto=on' >> /etc/pretix/pretix.cfg && \
    echo 'registration=off' >> /etc/pretix/pretix.cfg && \
    echo '' >> /etc/pretix/pretix.cfg && \
    echo '[locale]' >> /etc/pretix/pretix.cfg && \
    echo 'default=de' >> /etc/pretix/pretix.cfg && \
    echo 'timezone=Europe/Berlin' >> /etc/pretix/pretix.cfg && \
    echo '' >> /etc/pretix/pretix.cfg && \
    echo '[database]' >> /etc/pretix/pretix.cfg && \
    echo 'backend=postgresql' >> /etc/pretix/pretix.cfg && \
    echo 'name=pretix' >> /etc/pretix/pretix.cfg && \
    echo 'user=pretix' >> /etc/pretix/pretix.cfg && \
    echo 'password=pretix' >> /etc/pretix/pretix.cfg && \
    echo 'host=database' >> /etc/pretix/pretix.cfg && \
    echo '' >> /etc/pretix/pretix.cfg && \
    echo '[redis]' >> /etc/pretix/pretix.cfg && \
    echo 'location=redis://cache/0' >> /etc/pretix/pretix.cfg && \
    echo 'sessions=true' >> /etc/pretix/pretix.cfg && \
    echo '' >> /etc/pretix/pretix.cfg && \
    echo '[celery]' >> /etc/pretix/pretix.cfg && \
    echo 'backend=redis://cache/1' >> /etc/pretix/pretix.cfg && \
    echo 'broker=redis://cache/2' >> /etc/pretix/pretix.cfg

EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]