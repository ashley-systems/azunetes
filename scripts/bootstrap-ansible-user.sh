#!/usr/bin/env bash

set -euo pipefail

readonly ANSIBLE_USER="ansible"

usage() {
  cat <<'EOF'
Usage:
  bootstrap-ansible-user.sh --authorized-key "<OpenSSH public key>"

Options:
  --authorized-key   OpenSSH public key for GitHub Actions access
  --help             Show this help message
EOF
}

error() {
  printf 'Error: %s\n' "$1" >&2
}

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    error "this script must be run as root"
    exit 1
  fi
}

require_commands() {
  local cmd

  for cmd in cut getent grep id install chown chmod useradd usermod; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "required command not found: $cmd"
      exit 1
    fi
  done
}

validate_public_key() {
  local key="$1"
  local pattern='^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh\.com|sk-ecdsa-sha2-nistp256@openssh\.com) [A-Za-z0-9+/=]+( .*)?$'

  if [[ -z "$key" || ! "$key" =~ $pattern ]]; then
    error "invalid OpenSSH public key format"
    exit 2
  fi
}

parse_args() {
  AUTHORIZED_KEY=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --authorized-key)
        if [[ $# -lt 2 ]]; then
          error "missing value for --authorized-key"
          exit 2
        fi
        AUTHORIZED_KEY="$2"
        shift 2
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        error "unknown argument: $1"
        exit 2
        ;;
    esac
  done

  if [[ -z "${AUTHORIZED_KEY}" ]]; then
    error "--authorized-key is required"
    exit 2
  fi

  validate_public_key "${AUTHORIZED_KEY}"
}

ensure_user() {
  if getent passwd "${ANSIBLE_USER}" >/dev/null 2>&1; then
    printf 'user exists\n'
    return
  fi

  useradd --create-home --shell /bin/bash "${ANSIBLE_USER}"
  printf 'user created\n'
}

get_user_home() {
  getent passwd "${ANSIBLE_USER}" | cut -d: -f6
}

ensure_authorized_key() {
  local home_dir ssh_dir authorized_keys

  home_dir="$(get_user_home)"
  ssh_dir="${home_dir}/.ssh"
  authorized_keys="${ssh_dir}/authorized_keys"

  install -d -m 0700 -o "${ANSIBLE_USER}" -g "${ANSIBLE_USER}" "${ssh_dir}"

  if [[ ! -f "${authorized_keys}" ]]; then
    install -m 0600 -o "${ANSIBLE_USER}" -g "${ANSIBLE_USER}" /dev/null "${authorized_keys}"
  else
    chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${authorized_keys}"
    chmod 0600 "${authorized_keys}"
  fi

  if grep -Fxq -- "${AUTHORIZED_KEY}" "${authorized_keys}"; then
    printf 'key already present\n'
    return
  fi

  printf '%s\n' "${AUTHORIZED_KEY}" >> "${authorized_keys}"
  chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${authorized_keys}"
  chmod 0600 "${authorized_keys}"
  printf 'key added\n'
}

ensure_sudo_access() {
  if ! getent group sudo >/dev/null 2>&1; then
    error "sudo group not found"
    exit 1
  fi

  if id -nG "${ANSIBLE_USER}" | grep -qw sudo; then
    printf 'sudo group already assigned\n'
    return
  fi

  usermod -aG sudo "${ANSIBLE_USER}"
  printf 'sudo group assigned\n'
}

main() {
  parse_args "$@"
  require_root
  require_commands
  ensure_user
  ensure_authorized_key
  ensure_sudo_access
}

main "$@"
