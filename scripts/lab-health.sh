#!/usr/bin/env bash
# Verifica o estado do lab (VMs, rede do exame, repo HTTP, pacotes e discos).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

lab_cd
lab_require_tools

VMS=(repo server1 server2)
LAB_IPS=(192.168.55.149 192.168.55.150 192.168.55.151)
FAILURES=0

section() { echo; echo "=== $* ==="; }
bump_fail() { FAILURES=$((FAILURES + 1)); }

check_vm_running() {
  local vm=$1
  if lab_vagrant_running "${vm}"; then
    lab_ok "${vm}: VM running"
  else
    lab_fail "${vm}: VM not running"
    bump_fail
    return 1
  fi
}

check_ssh() {
  local vm=$1
  local cmd=$2
  local label=$3
  if lab_ssh "${vm}" "${cmd}" >/dev/null 2>&1; then
    lab_ok "${vm}: ${label}"
  else
    lab_fail "${vm}: ${label}"
    bump_fail
  fi
}

section "Vagrant"
if ! vagrant status >/dev/null 2>&1; then
  lab_fail "vagrant status falhou (corra a partir de ${LAB_DIR})"
  exit 1
fi
vagrant status | sed 's/^/  /'

section "VMs (provider)"
for vm in "${VMS[@]}"; do
  check_vm_running "${vm}" || true
done

section "Rede do exame (eth1 / 192.168.55.0/24)"
for i in "${!VMS[@]}"; do
  vm=${VMS[$i]}
  ip=${LAB_IPS[$i]}
  if ! lab_vagrant_running "${vm}"; then
    lab_warn "${vm}: skip (VM down)"
    continue
  fi
  if lab_ssh "${vm}" "ip -4 addr show eth1 2>/dev/null | grep -q '${ip}/'"; then
    lab_ok "${vm}: eth1 ${ip}"
  else
    lab_fail "${vm}: eth1 sem ${ip}"
    bump_fail
  fi
done

section "Repo (mirror HTTP)"
if lab_vagrant_running repo; then
  check_ssh repo \
    "curl -sfI http://127.0.0.1/BaseOS/repodata/repomd.xml | head -1 | grep -q '200'" \
    "BaseOS repomd.xml HTTP 200"
  check_ssh repo \
    "curl -sfI http://127.0.0.1/AppStream/repodata/repomd.xml | head -1 | grep -q '200'" \
    "AppStream repomd.xml HTTP 200"
  check_ssh repo "systemctl is-active httpd" "httpd active"
  check_ssh repo "systemctl is-active firewalld" "firewalld active"
else
  lab_warn "repo: skip checks (VM down)"
fi

section "Server 1 (estado do lab)"
if lab_vagrant_running server1; then
  check_ssh server1 "rpm -q httpd" "httpd instalado"
  check_ssh server1 "systemctl is-active httpd" "httpd active"
  check_ssh server1 "test ! -f /etc/yum.repos.d/rpms.repo && [ -z \"\$(ls -A /etc/yum.repos.d 2>/dev/null)\" ]" \
    "sem repos em /etc/yum.repos.d"
  check_ssh server1 "getenforce | grep -q Enforcing" "SELinux enforcing"
else
  lab_warn "server1: skip checks (VM down)"
fi

section "Server 2 (estado do lab + discos)"
if lab_vagrant_running server2; then
  check_ssh server2 "rpm -q httpd man-pages" "httpd + man-pages instalados"
  check_ssh server2 "systemctl is-active httpd" "httpd active"
  check_ssh server2 "test ! -f /etc/yum.repos.d/rpms.repo && [ -z \"\$(ls -A /etc/yum.repos.d 2>/dev/null)\" ]" \
    "sem repos em /etc/yum.repos.d"
  check_ssh server2 "lsblk -dn -o NAME,SIZE,LABEL,MOUNTPOINT | grep -E 'vdb|vdc|sdb|sdc'" \
    "discos extras vdb/vdc (ou sdb/sdc) presentes"
  check_ssh server2 "mountpoint -q /extradisk1 && mountpoint -q /extradisk2" \
    "/extradisk1 e /extradisk2 montados"
  echo "  --- lsblk (server2) ---"
  lab_ssh server2 "lsblk -o NAME,SIZE,TYPE,LABEL,MOUNTPOINT" 2>/dev/null | sed 's/^/  /' || lab_fail "lsblk"
else
  lab_warn "server2: skip checks (VM down)"
fi

section "Resumo"
if ((FAILURES == 0)); then
  echo "  Lab saudável (0 falhas)."
  exit 0
fi
echo "  ${FAILURES} verificação(ões) falharam."
echo "  Dicas: ./scripts/lab-up.sh | vagrant provision repo | vagrant provision server1"
echo "         vagrant provision server2  # só discos/shell"
exit 1
