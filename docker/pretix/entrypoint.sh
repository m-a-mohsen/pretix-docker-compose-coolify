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

tpl_path = os.environ.get('IMAGE_CONFIG_DIR','/image/config') + '/pretix.cfg.template'
try:
    with open(tpl_path,'r') as f:
        tpl = Template(f.read())
except FileNotFoundError:
    print('Template not found:', tpl_path)
    raise SystemExit(0)

# Use environment to substitute; safe_substitute leaves unknowns untouched
rendered = tpl.safe_substitute(os.environ)

targets = ['/etc/pretix/pretix.cfg', os.environ.get('IMAGE_CONFIG_DIR','/image/config') + '/pretix.cfg']
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
exec pretix "$@"
