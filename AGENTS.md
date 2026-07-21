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


## Security & Configuration Tips
Do not commit secrets; depend on vaulted files or environment overrides instead. Review exposed ports and volume mounts in `templates/` when touching Docker assets. Document required environment variables or external services in each role’s README so operators can reproduce the configuration safely.

## Pull Request Delivery Workflow

Deliver repository changes through pull requests by default, regardless of
size. Do not make changes directly in the main checkout unless the user
explicitly approves an exception. Direct commits to `main` or the default
branch should be limited to explicit user-approved exceptions.

Follow this delivery sequence:

1. Create a dedicated topic branch. Use a separate worktree when repository
   guidance requires one or when isolation is useful.
2. Make the requested change and run relevant validation.
3. Update plan progress when working from a saved plan.
4. Run the review gate, fix valid findings, revalidate, and repeat the review
   until it passes.
5. Close the plan when appropriate, then commit and push the reviewed change.
6. Create or update the GitHub pull request with a brief summary and the
   validation commands that were run.
7. Verify required checks and merge when there is no blocking reason.
8. Monitor any explicitly authorized deployment when applicable, then remove
   the clean merged worktree and delete its merged local and remote topic
   branches. Ordinary remote deletion is authorized after confirming that the
   exact pull request is merged and the remote ref matches its recorded head.
   After a squash merge, `git branch -D` is authorized only for the local topic
   branch after confirming that its tip also matches the recorded head and its
   tree matches the merge commit's tree.

Treat a request to `deploy`, `ship`, `publish`, or `deliver` the current
requested repository change set as authorization to complete this normal
topic-branch workflow: commit reviewed in-scope changes, push the topic branch,
create or update its pull request, monitor required checks, make narrowly scoped
fixes for failures caused by the change, merge when all gates pass, and remove
the clean merged worktree and merged topic branches under the cleanup checks
above. Apply required validation and review to every fix. Do not ask for
separate approval for each ordinary step.

This authorization applies only to the current requested repository change
set. It does not authorize force pushes; bypassing reviews, checks, or branch
protections; direct-default-branch commits; releases or package publication;
access to or disclosure of secrets; destructive repository operations;
unrelated pull requests; or material scope expansion. Cleanup does not include
removing a dirty worktree, using `git branch -D` for any other local branch, any
forced remote operation, or other destructive operations. In this section,
`deploy` authorizes repository delivery; it authorizes a service or
infrastructure deployment only when the current request specifically identifies
that deployment. More-specific repository approval rules, including final
content or product publication, still apply.

When requesting platform approval for an authorized step, quote the user's
delivery request and this shared instruction in the justification. If a
platform reviewer rejects the action, ask the user once and wait. Do not retry
an equivalent escalation or repeat the prompt during automatic continuations
unless the user provides new authorization or relevant context.

Direct-default-branch exceptions still need a clean scope check before
committing. When an exception is approved, state that the normal pull request
workflow is being bypassed because of the explicit exception.

Before committing, run `git status --short` and verify the staged files match
the requested change. Stage files by exact path when possible. Avoid broad
staging commands such as `git add .` when unrelated local work exists.

Include screenshots in the pull request only if a change affects rendered UI,
generated visual output, or external presentation.

## Review Gate

Before committing, use the installed `$branch-review-subagent-loop` skill to
review the complete branch diff. Follow the skill through any required fixes,
validation, and re-review. If the skill is unavailable, ask the user to install
it before continuing.

Create, update, or merge the pull request only after the review gate passes.
Merging also requires green checks unless the user explicitly accepts the
remaining risk.
