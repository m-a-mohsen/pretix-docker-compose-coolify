Installing Pretix plugins and building images

This repository supports adding Pretix plugins at image-build time and compiling production assets at container startup. Use the instructions below to build, verify and deploy a custom image with plugins (example: pretix-manualseats).

1. Build locally (PyPI install)

From the repository root run:

```bash
docker build --build-arg PRETIX_PLUGINS="pretix-manualseats" -t registry.example.com/you/mypretix:manualseats ./docker/pretix
```

Notes:

- The Dockerfile will `pip install` packages listed in `PRETIX_PLUGINS` during build.
- `make production` is no longer run at build time. The entrypoint will run `make production` at container startup on first run so services like Redis are available.

2. Push to registry and configure Dokploy/Coolify

```bash
docker login registry.example.com
docker push registry.example.com/you/mypretix:manualseats
```

Then update your Dokploy/Coolify service to use the image `registry.example.com/you/mypretix:manualseats` and redeploy.

3. Build on the Dokploy host (alternative)

If you must build on the Dokploy host, SSH into the host and run the same `docker build` command from the project's `docker/pretix` directory. See the repository path under `/etc/dokploy/compose/<project>/code` on the host.

4. Verify plugin and assets after deploy

```bash
# inside the running app container (adjust container name)
docker exec -it pretixv2v-yr3x9o-app-1 pip show pretix-manualseats || true
docker exec -it pretixv2v-yr3x9o-app-1 ls -la /pretix/src/static || true
docker exec -it pretixv2v-yr3x9o-app-1 cat /pretix/.plugins_built || true
```

5. Troubleshooting

- If `pip install` fails during build with native compile errors, add the required system packages before running pip, for example:

```dockerfile
RUN apt-get update && apt-get install -y build-essential libxml2-dev libxslt-dev && rm -rf /var/lib/apt/lists/*
```

- If you hit registry auth issues when using COPY--from workflows, prefer the PyPI route above or configure GHCR auth with a PAT.

6. Optional: automated CI

If you want, add a GitHub Action (or CI job) that builds the image on push and pushes it to a registry. I can create a sample GitHub Actions workflow for you that builds with `PRETIX_PLUGINS` and pushes `registry.example.com/you/mypretix:latest` on tag or branch.
