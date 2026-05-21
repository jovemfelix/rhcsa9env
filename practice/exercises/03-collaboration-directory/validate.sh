#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server1
EXERCISE=03-collaboration-directory

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'test -d /home/managers' 'diretório /home/managers existe'

assert_ssh "${VM}" 'stat -c "%G" /home/managers | grep -qx sysmgrs' 'grupo do diretório é sysmgrs'

assert_ssh "${VM}" 'stat -c "%a" /home/managers | grep -qE "2770|2700"' \
  'permissões incluem setgid (2770 ou equivalente)'

assert_ssh "${VM}" '[ "$(stat -c "%a" /home/managers | rev | cut -c1)" = "0" ]' \
  'outros utilizadores sem permissão (other=0)'

assert_ssh "${VM}" 'sudo -u natasha touch /home/managers/.labtest 2>/dev/null; stat -c "%G" /home/managers/.labtest | grep -qx sysmgrs' \
  'ficheiro novo de natasha herda grupo sysmgrs'

lab_ssh "${VM}" 'rm -f /home/managers/.labtest' 2>/dev/null || true

finish_validation "${EXERCISE}"
