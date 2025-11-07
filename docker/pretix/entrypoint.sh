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

# Merge environment with defaults (environment wins)
env = dict(os.environ)
for k,v in defaults.items():
    env.setdefault(k, v)

rendered = tpl.safe_substitute(env)

targets = ['/etc/pretix/pretix.cfg', tpl_dir + '/pretix.cfg']
for t in targets:
    try:
        write_path = t
        # If the target path exists and is a directory, write the file inside it
        if os.path.isdir(t):
            write_path = os.path.join(t, 'pretix.cfg')
        else:
            parent = os.path.dirname(t)
            # Ensure parent directory exists
            if parent and not os.path.isdir(parent):
                os.makedirs(parent, exist_ok=True)

        with open(write_path,'w') as f:
            f.write(rendered)
        print('Wrote', write_path)
    except Exception as e:
        print('Failed writing', t, e)

PY
fi

# Exec pretix with whatever arguments were provided. The base image expects
# the command to be run as the container's user (we keep existing USER in Dockerfile).
exec pretix "$@"
