#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server2
EXERCISE=08-secondary-ip-server2

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'ip -4 addr show eth1 | grep -q "192.168.55.151/24"' \
  'eth1 mantém IP primário 192.168.55.151'

assert_ssh "${VM}" 'ip -4 addr show eth2 | grep -q "192.168.55.175/24"' \
  'eth2 configurado com 192.168.55.175/24'

assert_ssh "${VM}" 'nmcli -t -f DEVICE,STATE device status | grep -E "^eth2:connected"' \
  'eth2 connected no NetworkManager'

finish_validation "${EXERCISE}"
