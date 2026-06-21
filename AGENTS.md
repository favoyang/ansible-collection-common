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
Keep commit subjects short and imperative (e.g. `Add docker compose fixture`).
Group related code per commit. Use pull requests for fixes by default,
including small follow-up fixes. Do not make fixes directly in the main checkout
unless the user explicitly approves an exception. Before committing, run
`git status --short` and verify the staged files match the requested change.
Stage files by exact path when possible. Avoid broad staging commands such as
`git add .` when unrelated local work exists. Pull requests should call out the
roles touched, tests or lint commands run, fixture updates, and any follow-up
work. Link issues when available and request review from maintainers familiar
with the affected role.

## Code Review Fix Loop
Run local PR code review before creating or updating the GitHub PR. Review the
full diff as a pull request: prioritize bugs, regressions, missing tests,
incorrect assumptions, deployment risk, and mismatches with the requested
behavior. Do not merge until local PR code review passes or the user explicitly
waives it.

Make review fixes in the same PR branch or worktree that introduced the change.
Re-run the relevant validation after fixes, then run local PR code review again.
Repeat the local review and fix loop until there are no blocking findings.

Commit the reviewed change only after validation and local PR code review pass.
After pushing, create or update the GitHub PR. Keep the PR summary current with
the final change scope and validation commands that were run. Merge only after
the local review fix loop passes and checks are green, or the user explicitly
accepts the remaining risk.

## Security & Configuration Tips
Do not commit secrets; depend on vaulted files or environment overrides instead. Review exposed ports and volume mounts in `templates/` when touching Docker assets. Document required environment variables or external services in each role’s README so operators can reproduce the configuration safely.
