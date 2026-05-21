# shellcheck shell=bash
# Shared helpers for practice/exercises/*/validate.sh

PRACTICE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${PRACTICE_LIB_DIR}/../.." && pwd)"

PASS=0
FAIL=0

lab_cd_project() { cd "${PROJECT_ROOT}"; }

check_vagrant_vm() {
  local vm=$1
  if ! (cd "${PROJECT_ROOT}" && vagrant status "${vm}" 2>/dev/null | grep -qE "^${vm}[[:space:]]+running"); then
    echo "FAIL: VM '${vm}' não está running. Use: vagrant up ${vm}"
    exit 1
  fi
}

# lab_ssh VM 'comando'
lab_ssh() {
  local vm=$1
  local cmd=$2
  lab_cd_project
  vagrant ssh "${vm}" -c "${cmd}" 2>/dev/null
}

assert_ssh() {
  local vm=$1
  local cmd=$2
  local msg_pt=$3
  if lab_ssh "${vm}" "${cmd}"; then
    echo "OK: ${msg_pt}"
    PASS=$((PASS + 1))
  else
    echo "FAIL: ${msg_pt}"
    FAIL=$((FAIL + 1))
  fi
}

assert_ssh_not() {
  local vm=$1
  local cmd=$2
  local msg_pt=$3
  if lab_ssh "${vm}" "${cmd}"; then
    echo "FAIL: ${msg_pt}"
    FAIL=$((FAIL + 1))
  else
    echo "OK: ${msg_pt}"
    PASS=$((PASS + 1))
  fi
}

finish_validation() {
  local exercise=${1:-exercise}
  echo
  echo "=== Resumo (${exercise}) ==="
  echo "  Passou: ${PASS} | Falhou: ${FAIL}"
  if ((FAIL == 0)); then
    echo "  Resultado: correto para os critérios automáticos."
    echo "  (No exame real podem existir outros critérios; reveja o enunciado.)"
    return 0
  fi
  echo "  Resultado: ainda não está correto. Vê VALIDATION.md nesta pasta."
  return 1
}
