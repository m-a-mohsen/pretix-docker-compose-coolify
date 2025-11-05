# Pretix Environment Variables Configuration

This deployment uses environment variables instead of a configuration file for Pretix settings.

## Required Environment Variables

### Basic Settings
- `PRETIX_INSTANCE_NAME` - Name of your Pretix installation
- `PRETIX_URL` - Full URL of your installation (e.g., https://tickets.example.com)
- `PRETIX_CURRENCY` - Default currency (e.g., EUR, USD)
- `PRETIX_DATADIR` - Data directory (should be /data)
- `PRETIX_TRUST_X_FORWARDED_FOR` - Set to "on" for proxy setups
- `PRETIX_TRUST_X_FORWARDED_PROTO` - Set to "on" for proxy setups
- `PRETIX_REGISTRATION` - Set to "off" to disable public registration

### Locale Settings
- `PRETIX_DEFAULT_LOCALE` - Default language (e.g., de, en)
- `PRETIX_TIMEZONE` - Default timezone (e.g., Europe/Berlin)

### Database Settings
- `PRETIX_DATABASE_BACKEND` - Database backend (postgresql)
- `PRETIX_DATABASE_NAME` - Database name
- `PRETIX_DATABASE_USER` - Database username
- `PRETIX_DATABASE_PASSWORD` - Database password
- `PRETIX_DATABASE_HOST` - Database hostname

### Redis Settings
- `PRETIX_REDIS_LOCATION` - Redis connection URL
- `PRETIX_REDIS_SESSIONS` - Set to "true" to use Redis for sessions

### Celery Settings
- `PRETIX_CELERY_BACKEND` - Celery result backend URL
- `PRETIX_CELERY_BROKER` - Celery broker URL

### Mail Settings (Optional)
Configure these through Coolify environment variables or secrets:
- `PRETIX_MAIL_FROM` - From email address
- `PRETIX_MAIL_HOST` - SMTP server hostname
- `PRETIX_MAIL_USER` - SMTP username
- `PRETIX_MAIL_PASSWORD` - SMTP password
- `PRETIX_MAIL_PORT` - SMTP port (usually 587)
- `PRETIX_MAIL_TLS` - Set to "on" for TLS
- `PRETIX_MAIL_SSL` - Set to "on" for SSL

## Coolify Integration

In Coolify, you can set these environment variables in the application settings. Use Coolify's secrets feature for sensitive values like passwords.

## Migration from Config File

The original `pretix.cfg` file has been backed up as `pretix.cfg.backup`. If you need to revert, restore this file and update the docker-compose.yml volume mount.