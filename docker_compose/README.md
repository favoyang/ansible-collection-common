# Docker Compose Role

Deploys and manages Docker Compose applications with support for both static and templated configuration files.

## How it works

The role copies files from a local directory to a remote directory and manages Docker Compose:

- **Static files**: `docker-compose.yml`, `.env` → copied directly
- **Template files**: `docker-compose.yml.j2`, `.env.j2` → rendered with Jinja2
- **Priority**: Template files (`.j2`) take precedence over static files
- **Docker operations**: Uses `community.docker.docker_compose_v2` module to pull latest images and recreate containers

## Usage

### Direct Role Usage

```yaml
- hosts: servers
  roles:
    - docker_compose
  vars:
    docker_compose_local_dir: files/myapp
    docker_compose_remote_dir: /srv/myapp
```

### Include Role Pattern

When including this role from another role, **always preserve the current role path first**:

```yaml
- name: Setup application with docker compose
  block:
    - name: Preserve current role path for docker compose setup
      set_fact:
        current_role_path: "{{ role_path }}"
    
    - name: Setup application with docker compose
      include_role:
        name: docker_compose
      vars:
        docker_compose_local_dir: "{{ current_role_path }}/files"
        docker_compose_remote_dir: /srv/myapp
```

**Why this pattern is required**:

- **Context change**: `include_role` changes the evaluation context, so `{{ role_path }}` in `vars:` points to the included role, not the calling role
- **`set_fact` solution**: Preserves the calling role's path before the context changes
- **Runtime processing**: `include_role` processes at runtime, so variables from previous tasks are available

**❌ Wrong approach** (will cause incorrect paths):
```yaml
- name: Setup application with docker compose
  include_role:
    name: docker_compose
  vars:
    docker_compose_local_dir: "{{ role_path }}/files"  # role_path = docker_compose path!
    docker_compose_remote_dir: /srv/myapp
```

### File Structure Example

```
files/myapp/
├── docker-compose.yml          # Static file (copied as-is)
├── docker-compose.yml.j2       # Template file (rendered, takes precedence)
├── .env                        # Static environment file
└── .env.j2                     # Template environment file (rendered, takes precedence)
```

## Variables

### Required Variables
- `docker_compose_local_dir`: Local directory containing docker-compose files (e.g., `files/myapp`)
- `docker_compose_remote_dir`: Remote directory where files will be deployed (e.g., `/srv/myapp`)
