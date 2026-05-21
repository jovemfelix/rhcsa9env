# shellcheck shell=bash
# Shared helpers for lab scripts (source, do not execute directly).

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

lab_cd() {
  cd "${LAB_DIR}"
}

lab_require_tools() {
  local missing=()
  for cmd in vagrant "$@"; do
    command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
  done
  if ((${#missing[@]} > 0)); then
    echo "ERROR: ferramentas em falta: ${missing[*]}" >&2
    exit 1
  fi
}

lab_vagrant_running() {
  local name=$1
  vagrant status "${name}" 2>/dev/null | grep -qE "^${name}[[:space:]]+running"
}

lab_ssh() {
  local vm=$1
  shift
  vagrant ssh "${vm}" -c "$*"
}

lab_ok()   { echo "  OK   $*"; }
lab_warn() { echo "  WARN $*"; }
lab_fail() { echo "  FAIL $*"; }
