#!/bin/sh
set -e

# Render pretix.cfg from template if present. This uses Python's Template
# to expand ${VAR} placeholders from the environment into the final config.
TEMPLATE_PATH="${IMAGE_CONFIG_DIR:-/image/config}/pretix.cfg.template"
TARGET1="/etc/pretix/pretix.cfg"
TARGET2="${IMAGE_CONFIG_DIR:-/image/config}/pretix.cfg"

if [ -f "$TEMPLATE_PATH" ]; then
  echo "Rendering $TEMPLATE_PATH -> $TARGET1 and $TARGET2"
  python3 - <<'PY'
import os
from string import Template

tpl_dir = os.environ.get('IMAGE_CONFIG_DIR','/image/config')
tpl_path = tpl_dir + '/pretix.cfg.template'
try:
    with open(tpl_path,'r') as f:
        tpl = Template(f.read())
except FileNotFoundError:
    print('Template not found:', tpl_path)
    raise SystemExit(0)

# Provide reasonable defaults for variables used in the template.
defaults = {
    'PRETIX_INSTANCE_NAME': 'localhost',
    'PRETIX_URL': 'http://localhost',
    'PRETIX_CURRENCY': 'EUR',
    'PRETIX_DATADIR': '/data',
    'PRETIX_REGISTRATION': 'off',
    'PRETIX_LOCALE_DEFAULT': 'de',
    'PRETIX_TIMEZONE': 'Europe/Berlin',
    'DB_BACKEND': 'postgresql',
    'DB_NAME': 'pretix',
    'DB_USER': 'pretix',
    'DB_PASSWORD': 'pretix',
    'DB_HOST': 'database',
    'MAIL_FROM': 'no-reply@example.com',
    'MAIL_HOST': 'localhost',
    'MAIL_USER': '',
    'MAIL_PASSWORD': '',
    'MAIL_PORT': '587',
    'MAIL_TLS': 'off',
    'MAIL_SSL': 'off',
    'REDIS_LOCATION': 'redis://cache/0',
    'REDIS_SESSIONS': 'true',
    'CELERY_BACKEND': 'redis://cache/1',
    'CELERY_BROKER': 'redis://cache/2',
}

# Merge environment with defaults. Treat empty environment variables as
# "not set" so that defaults are used instead of writing empty values
env = dict(os.environ)
for k, v in defaults.items():
    # If the variable is not present or is an empty string, use the default
    if not env.get(k):
        env[k] = v

rendered = tpl.safe_substitute(env)

targets = ['/etc/pretix/pretix.cfg', tpl_dir + '/pretix.cfg']
for t in targets:
    try:
        with open(t,'w') as f:
            f.write(rendered)
        print('Wrote', t)
    except Exception as e:
        print('Failed writing', t, e)

PY
fi

# Exec pretix with whatever arguments were provided. The base image expects
# the command to be run as the container's user (we keep existing USER in Dockerfile).
# If plugins were provided at build time (or image was built with PRETIX_PLUGINS),
# ensure production assets are (re)built at container start when services like
# Redis are available. We guard with a marker file so this runs only once.
if [ -n "$PRETIX_PLUGINS" ] || [ -d /plugins ] ; then
    if [ -d /pretix/src ] && [ ! -f /pretix/.plugins_built ]; then
        echo "Building production assets because PRETIX_PLUGINS is set or /plugins exists"
            # run make production; if it fails we do NOT create the marker file so
            # the step will be retried on the next start when services may be ready.
            if (cd /pretix/src && make production); then
                echo "make production succeeded"
                touch /pretix/.plugins_built || true
            else
                echo "make production failed; will retry on next start"
                # increment failure counter and fail hard after 3 attempts
                ATTEMPTS_FILE=/pretix/.plugins_failed_attempts
                if [ -f "$ATTEMPTS_FILE" ]; then
                    attempts=$(cat "$ATTEMPTS_FILE" 2>/dev/null || echo 0)
                else
                    attempts=0
                fi
                attempts=$((attempts + 1))
                echo "$attempts" > "$ATTEMPTS_FILE" || true
                echo "make production has failed $attempts time(s)"
                if [ "$attempts" -ge 3 ]; then
                    echo "make production failed $attempts times — exiting to surface the error" >&2
                    exit 1
                fi
            fi
    fi
fi

# Some orchestrators (Dokploy/Coolify) may override the container command
# with things like `tail -f /dev/null` to keep the container running. The
# pretix CLI does not have a "tail" command and will error with
# "Unknown command: 'tail'" if we blindly `exec pretix "$@"`.
#
# If the first argument is `tail` (or another plain shell command), run it
# directly instead of calling `pretix`.
if [ "${1:-}" = "tail" ] || [ "${1:-}" = "sh" ] || [ "${1:-}" = "bash" ]; then
    exec "$@"
fi

exec pretix "$@"
