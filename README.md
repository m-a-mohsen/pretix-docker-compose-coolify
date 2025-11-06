# Pretix Docker-Compose setup
The repository includes a [Pretix](https://pretix.eu/about/de/) docker-compose configuration for local development.

## Usage

You can execute `docker-compose up -d --build --force-recreate` to start and build all related containers.

### Version information

| **Version** |                         **Description**                          |
|:-----------:|:----------------------------------------------------------------:|
|    1.2.0    |                      Includes PostgreSQL 17                      |
|    1.1.1    | Update the Alpine version and the allocated IPs of the databases |
|    1.1.0    |                      Includes PostgreSQL 16                      |
|    1.0.0    |                      Includes PostgreSQL 13                      |

### Cronjobs

It is possible to adapt the `pretixuser` crontab entries by modifying the [crontab](docker/pretix/crontab) file.

## TLS setup

You can specify the used TLS certificates by adapting the mounted [certificate](docker/pretix/files/config/ssl/domain.crt) and [key](docker/pretix/files/config/ssl/domain.key) e.g. from Let's Encrypt or generating new self-signed certificates by following the [manual](scripts/EXAMPLE-CERT-CREATION.md) and moving the generated files. It is also possible to adapt the [used](docker/pretix/nginx/nginx.conf) Nginx configuration. 

## Contribution
If you would like to contribute something, have an improvement request, or want to make a change inside the code, please open a pull request.

## Support
If you need support, or you encounter a bug, please don't hesitate to open an issue.

## Donations
If you want to support my work, I ask you to take an unusual action inside the open source community. Donate the money to a non-profit organization like Doctors Without Borders or the Children's Cancer Aid. I will continue to build tools because I like them, and I am passionate about developing and sharing applications.

## License
This product is available under the Apache 2.0 license.

## Deploying to Coolify

This repository contains a Pretix docker-compose configuration adjusted to run under Coolify (Traefik). Key notes:

- Traefik (managed by Coolify) will terminate TLS for you. The container listens on port 80.
- Configuration is provided via environment variables (see `.env.example`). In Coolify, paste the variables in the app's environment editor or use secrets for sensitive values.
- We baked `nginx/nginx.conf` into the image to avoid host bind-mount mismatches when Coolify creates application folders.

Quick steps to deploy on Coolify:

1. Push this branch to your Git remote.
2. Create a new application in Coolify pointing to this repo and branch. Use the Dockerfile build context `./docker/pretix`.
3. In the Coolify app settings, add environment variables from `.env.example` (set real secrets via the GUI/secret store).
4. Ensure the app routes to container port `80` (Coolify will provision TLS automatically).
5. Deploy and monitor logs in Coolify. If you need to override cron or nginx locally, prefer uploading files through Coolify's file/volume options and ensure host path types match container paths (file vs directory).

If you want, I can add a short `deploy-to-coolify.md` with screenshots or automate a GitHub Action that deploys to Coolify on push.

Runtime templating (recommended)

- This repository now renders `pretix.cfg` from environment variables at container start. That makes the image safe to build once and configure at runtime via Coolify's environment/editor.
- Files added:
	- `docker/pretix/files/config/pretix.cfg.template` — a template with `${VAR}` placeholders for all pretix configuration values used in production (instance name, URL, DB, Redis, mail, locale, etc.).
	- `docker/pretix/entrypoint.sh` — an entrypoint script that safely renders the template into `/image/config/pretix.cfg` and `/etc/pretix/pretix.cfg` before exec'ing the `pretix` command.

How it works in Coolify

- Set application environment variables in Coolify (or paste keys from `.env.example`). Important keys:
	- `PRETIX_INSTANCE_NAME` (e.g. `v1.tickets.example.org`)
	- `PRETIX_URL` (e.g. `https://v1.tickets.example.org/`)
	- `PRETIX_LOCALE_DEFAULT` (e.g. `de`)
	- `CELERY_BROKER` / `BROKER_URL` / `CELERY_BROKER_URL` (e.g. `redis://cache/2`)
	- DB and MAIL settings from `.env.example`

- On container start the entrypoint will render the config from the runtime env and Pretix will read it. This avoids mismatches between a baked config and the environment Coolify provides.

Notes and caveats

- A fallback `docker/pretix/pretix.cfg` is still present in the image to help with local testing and to avoid hard failures during the migration; it will be overwritten by the rendered config at container start if the template file exists.
- If you mount a host file onto `/etc/pretix/pretix.cfg` or `/image/config/pretix.cfg` via Coolify file mounts, that will override the rendered file — remove such mounts or upload the intended file via Coolify.
- If you want a follow-up change, we can remove the baked fallback config to make the runtime template the single source of truth.

If you'd like, I can prepare a short `deploy-to-coolify.md` that walks through the Coolify UI steps and shows the exact env variables to paste.
