#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server1
EXERCISE=04-cron-natasha

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'systemctl is-active crond >/dev/null' 'serviço crond ativo'

# crontab -u requires root; vagrant ssh runs as user vagrant
assert_ssh "${VM}" 'sudo crontab -u natasha -l 2>/dev/null | grep -q "EX200 in progress"' \
  'crontab de natasha contém o comando'

assert_ssh "${VM}" 'sudo crontab -u natasha -l 2>/dev/null | grep -qE "^[[:space:]]*\\*/2[[:space:]]"' \
  'agendamento a cada 2 minutos (*/2)'

if lab_ssh "${VM}" 'sudo grep -q "EX200 in progress" /var/log/messages 2>/dev/null || sudo journalctl -q --grep "EX200 in progress" 2>/dev/null | head -1 | grep -q .'; then
  echo "OK: mensagem já apareceu nos logs"
  PASS=$((PASS + 1))
else
  echo "WARN: ainda sem linhas nos logs — espera 2 min ou confere crontab manualmente"
fi

finish_validation "${EXERCISE}"
