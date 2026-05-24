#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server2
EXERCISE=07-lvm-database-server2

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

diagnose_lv_name() {
  if lab_ssh "${VM}" 'sudo lvs datastore --noheadings -o lv_name 2>/dev/null | grep -qw datastore'; then
    echo "  DICA: existe LV \"datastore\" no VG — o enunciado pede LV \"database\"."
    echo "        sudo umount /mnt/database && sudo lvrename datastore datastore database && sudo mount -a"
  fi
}

assert_ssh "${VM}" '! mountpoint -q /extradisk2' \
  '/extradisk2 desmontado (vdc livre para LVM)'

assert_ssh "${VM}" 'sudo pvs --noheadings -o pv_name 2>/dev/null | grep -q /dev/vdc' \
  '/dev/vdc é physical volume'

# vgs --noheadings pode ter espaços à esquerda; -x em linha inteira falha
assert_ssh "${VM}" 'sudo vgs datastore &>/dev/null' \
  'volume group datastore existe'

assert_ssh "${VM}" 'sudo vgs datastore --noheadings -o vg_extent_size 2>/dev/null | grep -qi 16' \
  'physical extent size 16 MiB'

assert_ssh "${VM}" 'sudo lvs datastore/database &>/dev/null' \
  'logical volume database existe (VG/LV = datastore/database)'

assert_ssh "${VM}" 'sudo findmnt -n /mnt/database 2>/dev/null | grep -q ext4' \
  '/mnt/database montado (ext4)'

# Errado: /dev/mapper/datastore-datastore | Certo: datastore-database ou /dev/datastore/database
if lab_ssh "${VM}" 'sudo findmnt -n /mnt/database -o SOURCE 2>/dev/null | grep -q datastore-datastore'; then
  echo "FAIL: SOURCE é datastore-datastore (LV com nome errado)"
  diagnose_lv_name
  FAIL=$((FAIL + 1))
elif lab_ssh "${VM}" 'sudo findmnt -n /mnt/database -o SOURCE 2>/dev/null | grep -q database'; then
  echo "OK: /mnt/database montado no LV database (/dev/mapper/datastore-database)"
  PASS=$((PASS + 1))
else
  echo "FAIL: SOURCE de /mnt/database não referencia o LV database"
  lab_ssh "${VM}" 'sudo findmnt -n /mnt/database -o SOURCE' | sed 's/^/    /' || true
  FAIL=$((FAIL + 1))
fi

assert_ssh "${VM}" 'grep -q /mnt/database /etc/fstab' \
  'entrada em /etc/fstab para /mnt/database'

finish_validation "${EXERCISE}"
