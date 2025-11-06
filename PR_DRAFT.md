# PR: Make Pretix deployment Coolify-friendly and render config from runtime envs

## Summary

This change set adapts the existing Pretix docker-compose repository for reliable deployment on Coolify (Traefik), focusing on minimal runtime changes and avoiding host file mount mismatches. The primary goal is to let Coolify manage TLS and runtime configuration via environment variables, and to ensure Pretix reads its configuration from those env vars at container startup.

## Files added / updated

- **docker-compose.yml**
  - Removed published ports for the `app`, added `env_file: .env` and explicit environment mapping for Pretix/DB/Redis/Mail values, and added healthchecks for database and cache.

- **docker/pretix/Dockerfile**
  - Expose HTTP (80) only and copy a baked nginx config into the image.
  - Copy a fallback `pretix.cfg` and install an entrypoint script. Ensure `/image/config` and `/etc/pretix` are writable by the runtime user.

- **docker/pretix/nginx/nginx.conf**
  - Removed SSL/listen 443 directives — Traefik (Coolify) will terminate TLS. Nginx listens on port 80 only.

- **docker/pretix/pretix.cfg**
  - Kept as a fallback for local testing; content updated to reflect the deployed domain in this branch.

- **docker/pretix/files/config/pretix.cfg.template** (NEW)
  - A template with `${VAR}` placeholders for all runtime settings (instance_name, url, DB, Redis, mail, locale, etc.).

- **docker/pretix/entrypoint.sh** (NEW)
  - Runtime entrypoint that renders the template into `/image/config/pretix.cfg` and `/etc/pretix/pretix.cfg` using environment variables, then execs Pretix. Ensures runtime config is authoritative and matches Coolify-provided envs.

- **.env.example / .env**
  - Example and local env updated to include `PRETIX_LOCALE_DEFAULT=de` and Celery/Redis broker variables (`CELERY_BROKER`, `BROKER_URL`, `CELERY_BROKER_URL`).

- **.gitignore**
  - `.env` added to avoid committing secrets.

## Why these changes

- Coolify manages TLS via Traefik and may create directories / mount files differently than a local developer — single-file host mounts can lead to mount-type mismatches. Baking critical runtime files into the image caused mismatches between Coolify runtime envs and the baked config.

- Rendering `pretix.cfg` from environment variables at container start makes the image build once and be configurable at runtime via Coolify's environment/secret editor. This follows 12-factor principles and reduces the need to modify the image on each deployment.

- Using Redis as the Celery broker (configured via envs) prevents the default Celery AMQP fallback that tries to reach `localhost:5672` and fails when not present.

## What I tested

- Rebuilt the `app` image with the new entrypoint and template, recreated the container, and verified:
  - The build includes the entrypoint and template files.
  - Coolify build-time and runtime envs (as shown in helper/log output) can provide `PRETIX_INSTANCE_NAME`, `PRETIX_URL`, `PRETIX_LOCALE_DEFAULT=de`, and Redis broker variables.
  - With the rendered config present, Pretix no longer rejected the Host header.

## How to validate in Coolify

1. In the Coolify app settings, paste the environment variables from `.env.example` (set secure values for DB_PASSWORD and MAIL_* via secrets).
2. Ensure `CELERY_BROKER` is set (e.g., `redis://cache/2`) and copy that into `BROKER_URL` and `CELERY_BROKER_URL` if desired.
3. Deploy the app. Coolify should route traffic and terminate TLS. The entrypoint will render the config from the runtime env on startup.
4. Inspect application logs and ensure there are no `Unknown host` or `Default language` errors.

## Follow-ups (optional)

- Remove the baked fallback `docker/pretix/pretix.cfg` to avoid confusion and make the runtime-templated config the single source of truth.
- Add a CI job that validates the rendered config by building the image and running the container with a test env, then checking the rendered `/image/config/pretix.cfg` content.
- Add `deploy-to-coolify.md` with screenshots for the Coolify UI.

## Rollback plan

- Revert this branch (or deploy the previous commit) if unexpected behavior occurs. Coolify supports quick rollbacks.

## Notes

- If you mount a host file onto `/etc/pretix/pretix.cfg`, it will override the rendered file — avoid mounting single files in Coolify unless intentionally managing config files via uploaded host files.

---

Use this markdown as the PR description when opening a PR from `coolify-v4` into `main`.
