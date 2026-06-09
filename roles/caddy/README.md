# Caddy Role

Generic Caddy web server setup with Docker Compose, including configuration validation and static file serving.

## Usage

```yaml
- hosts: servers
  roles:
    - favoyang.common.caddy
  vars:
    # Required: Docker image reference used for validation and deployment
    caddy_image: "caddy:2"
    # Override the default bundled Caddyfile if desired
    caddy_caddyfile_template: "files/caddy/Caddyfile.j2"
    # Optional site config rendered under /srv/caddy/conf.d/
    caddy_site_template: "files/caddy/example-site.caddy.j2"
    # Optional: override the localhost validation command if needed
    caddy_local_docker_command: "docker"
```

All rendered site configs share `/srv/sites` inside the container, which is sourced from `/srv/caddy/sites` on the host. Place site-specific assets under paths like `/srv/caddy/sites/com.example.com` so the matching `conf.d` entry can reference them directly.

The role also preserves target-local Docker Compose snippets under
`/srv/caddy/docker-compose.d` by default. Snippets are merged with the role's
base Caddy compose on every run before Caddy is deployed. Use this for durable
site-specific container extensions, such as extra read-only mounts required by
a site config. Do not edit `/srv/caddy/docker-compose.yml` directly because the
role regenerates it.

Example snippet:

```yaml
services:
  caddy:
    volumes:
      - /srv/example-assets:/srv/example-assets:ro
```

Local configuration validation runs on the control host before the role updates
the remote Caddy files.

- macOS control host: uses `docker`
- Linux control host: uses `sudo docker`

Override `caddy_local_docker_command` if the control host uses rootless Docker
or another wrapper.

The validation flow uses `docker create`, `docker cp`, and `docker start`
instead of bind mounts so it works more reliably with macOS Docker backends
such as Colima.
