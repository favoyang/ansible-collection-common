#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/favoyang-common.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

for cmd in ansible-galaxy ansible-playbook ansible-lint yamllint; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Required command '${cmd}' not found in PATH" >&2
    exit 127
  fi
done

ANSIBLE_TMP="${TMP_DIR}/.ansible/tmp"
mkdir -p "${ANSIBLE_TMP}"

export ANSIBLE_CONFIG="${ROOT_DIR}/ansible.cfg"
export ANSIBLE_LOCAL_TEMP="${ANSIBLE_TMP}"
export ANSIBLE_REMOTE_TEMP="${ANSIBLE_TMP}"
export ANSIBLE_LINT_NODEPS=1

echo "Building collection artifact..."
ANSIBLE_LOCAL_TEMP="${ANSIBLE_TMP}" \
ANSIBLE_REMOTE_TEMP="${ANSIBLE_TMP}" \
ansible-galaxy collection build "${ROOT_DIR}" --output-path "${TMP_DIR}"

TARBALL="$(ls "${TMP_DIR}"/favoyang-common-*.tar.gz 2>/dev/null | head -n1)"
if [[ -z "${TARBALL}" ]]; then
  echo "Collection build did not produce an artifact" >&2
  exit 1
fi

COLLECTIONS_DIR="${TMP_DIR}/collections"
mkdir -p "${COLLECTIONS_DIR}"

echo "Installing collection into isolated path..."
ANSIBLE_LOCAL_TEMP="${ANSIBLE_TMP}" \
ANSIBLE_REMOTE_TEMP="${ANSIBLE_TMP}" \
ansible-galaxy collection install "${TARBALL}" --force -p "${COLLECTIONS_DIR}"

echo "Ensuring Galaxy dependencies are present..."
ANSIBLE_LOCAL_TEMP="${ANSIBLE_TMP}" \
ANSIBLE_REMOTE_TEMP="${ANSIBLE_TMP}" \
ansible-galaxy collection install community.docker -p "${COLLECTIONS_DIR}" >/dev/null

DEFAULT_COLLECTION_PATHS="${HOME}/.ansible/collections:/usr/share/ansible/collections"
export ANSIBLE_COLLECTIONS_PATH="${COLLECTIONS_DIR}:${DEFAULT_COLLECTION_PATHS}"

echo "Running ansible-lint..."
ANSIBLE_LINT_NODEPS=1 ansible-lint --offline "${ROOT_DIR}/roles"

echo "Running yamllint..."
yamllint "${ROOT_DIR}/galaxy.yml" "${ROOT_DIR}/roles"

echo "Syntax-checking integration playbooks..."
ANSIBLE_LOCAL_TEMP="${ANSIBLE_TMP}" \
ansible-playbook -i "${ROOT_DIR}/inventory/default" --syntax-check "${ROOT_DIR}/tests/integration/caddy.yml"

ANSIBLE_LOCAL_TEMP="${ANSIBLE_TMP}" \
ansible-playbook -i "${ROOT_DIR}/inventory/default" --syntax-check "${ROOT_DIR}/tests/integration/docker_compose.yml"

echo "All checks passed."
