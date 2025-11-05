FROM pretix/standalone:stable

# Create a simple startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Starting Pretix with configuration..."' >> /start.sh && \
    echo 'exec pretix all' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]