FROM pretix/standalone:stable

USER root

# Create config directory and copy configuration file
COPY pretix.cfg /etc/pretix/pretix.cfg

USER pretixuser

EXPOSE 80

ENTRYPOINT ["pretix"]
CMD ["all"]