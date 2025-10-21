# Repository Guidelines

## Project Structure & Module Organization
Each role lives at the repository root (`caddy/`, `docker_compose/`) and follows the usual layout: `tasks/main.yml` for orchestration, `defaults/main.yml` for overridable variables, `templates/` for Jinja sources, `meta/argument_specs.yml` for input contracts, and `meta/main.yml` with the Galaxy metadata required for installs. Mirror that layout when adding new roles and document required vars plus usage in the role `README.md`.

## Build, Test, and Development Commands
The bundled `ansible.cfg` points at the INI inventory `inventory/default`, so run commands from the repo root without extra flags:
- `ansible-playbook tests/caddy_role.yml --syntax-check` sanity-checks the Caddy role.
- `ansible-playbook tests/docker_compose_role.yml --syntax-check` does the same for the Docker Compose role.
- `ansible-lint caddy docker_compose` enforces Ansible best practices.
- `yamllint .` catches structural YAML issues early.

## Coding Style & Naming Conventions
Use two-space indentation in YAML and avoid tabs. Variables stay lowercase snake_case, prefixed with the role name when shared (`caddy_image`). Task names are imperative (“Deploy docker compose bundle”). Templates should rely on explicit filters for clarity. Run `ansible-lint` before opening a pull request to confirm metadata and style remain consistent.

## Testing Guidelines
Sample inventory lives in `inventory/default` and targets `localhost`. Role-specific playbooks in `tests/caddy_role.yml` and `tests/docker_compose_role.yml` hardcode the vars they need and use fixtures under `tests/fixtures/`. Copy that pattern when adding roles, then run `ansible-playbook … --check --diff` to prove idempotence. For broader coverage, add Molecule scenarios under `molecule/<role>/default/` and share any key outputs in review notes.

## Commit & Pull Request Guidelines
Keep commit subjects short and imperative (e.g. `Add docker compose fixture`). Group related code per commit. Pull requests should call out the roles touched, tests or lint commands run, fixture updates, and any follow-up work. Link issues when available and request review from maintainers familiar with the affected role.

## Security & Configuration Tips
Do not commit secrets; depend on vaulted files or environment overrides instead. Review exposed ports and volume mounts in `templates/` when touching Docker assets. Document required environment variables or external services in each role’s README so operators can reproduce the configuration safely.
