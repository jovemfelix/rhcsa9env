#!/usr/bin/env bash
# Restaura server1 e server2 ao estado inicial do lab (playbooks/reset.yml).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

lab_cd
lab_require_tools ansible-playbook

echo "==> Reset do lab (server1 + server2) via Ansible"
echo "    Playbook: playbooks/reset.yml"
echo

ansible-playbook playbooks/reset.yml "$@"

echo
echo "==> Reset enviado. server2 (e server1) podem estar a reiniciar."
echo "    Aguarde ~30s e valide com: ./scripts/lab-health.sh"
