#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server2
EXERCISE=07-lvm-database-server2

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'vgs datastore --noheadings -o vg_name 2>/dev/null | grep -qx datastore' \
  'volume group datastore existe'

assert_ssh "${VM}" 'vgs datastore --noheadings -o vg_extent_size 2>/dev/null | grep -q 16' \
  'physical extent size 16 MiB'

assert_ssh "${VM}" 'lvs datastore/database --noheadings 2>/dev/null | grep -q database' \
  'logical volume database existe'

assert_ssh "${VM}" 'findmnt /mnt/database | grep -q ext4' \
  '/mnt/database montado (ext4)'

assert_ssh "${VM}" 'grep -q /mnt/database /etc/fstab' \
  'entrada em /etc/fstab para /mnt/database'

finish_validation "${EXERCISE}"
