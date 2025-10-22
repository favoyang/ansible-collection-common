# favoyang.common collection

Reusable common Ansible roles for personal use, bundled as the `favoyang.common` collection.

## Installation

Install straight from git (works with any branch or tag):

```bash
ansible-galaxy collection install git+https://github.com/favoyang/ansible-collection-common.git
```

The collection declares a dependency on `community.docker`, so `ansible-galaxy` pulls it automatically. Re-run
`ansible-galaxy collection install community.docker` manually only if you are developing against an existing checkout
without reinstalling the collection artifact.

Once installed, roles are available via their fully qualified collection names (FQCNs), for example `favoyang.common.caddy`.

## Role documentation

- [`roles/caddy/README.md`](roles/caddy/README.md)
- [`roles/docker_compose/README.md`](roles/docker_compose/README.md)

## Development

### Requirements

- `ansible-core` (for `ansible-galaxy` and `ansible-playbook`)
- `ansible-lint`
- `yamllint`

### Workflow

Run the bundled verification script before committing changes:

```bash
./scripts/test_collection.sh
```

The script builds the collection artifact, installs it in an isolated workspace, re-installs required Galaxy
dependencies (like `community.docker`) into that workspace, then runs `ansible-lint`, `yamllint`, and the syntax-check
playbooks. It expects `ansible-galaxy`, `ansible-playbook`, `ansible-lint`, and `yamllint` to be available in `PATH`,
and requires network access the first time dependencies are fetched. On constrained environments that block POSIX
semaphores (for example, some sandboxed CI runners), `ansible-lint` may fail with `PermissionError: [Errno 13]
Permission denied`; in that case rerun the lint locally or on a host with full multiprocessing support. The bundled
`ansible.cfg` already targets the sample inventory in `inventory/default`; adjust as needed for your environment.
