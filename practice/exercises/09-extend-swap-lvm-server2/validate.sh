#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server2
EXERCISE=09-extend-swap-lvm-server2
# Swap inicial do lab: 2 GiB; exercício pede +512 MiB → ~2,5 GiB (PEs podem arredondar alguns KiB)
MIN_SWAP_MIB=2560
MIN_SWAP_KB=$((MIN_SWAP_MIB * 1024 - 8))

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" '! mountpoint -q /extradisk1' \
  '/extradisk1 desmontado (vdb livre para PV em centos9s)'

assert_ssh "${VM}" 'sudo pvs --noheadings -o pv_name,vg_name 2>/dev/null | awk "\$1==\"/dev/vdb\" && \$2==\"centos9s\" {found=1} END {exit !found}"' \
  '/dev/vdb é physical volume no volume group centos9s'

assert_ssh "${VM}" 'sudo vgs centos9s --noheadings -o vg_name 2>/dev/null | grep -q centos9s' \
  'volume group centos9s existe'

# Tamanho do LV swap >= 2,5 GiB (lvs em MiB)
if lab_ssh "${VM}" "sudo lvs centos9s/swap --noheadings -o lv_size --units m --nosuffix 2>/dev/null | awk '{print int(\$1)}' | awk -v min=${MIN_SWAP_MIB} '\$1 >= min {exit 0} {exit 1}'"; then
  echo "OK: LV swap em centos9s com pelo menos ${MIN_SWAP_MIB} MiB (~2,5 GiB)"
  PASS=$((PASS + 1))
else
  echo "FAIL: LV centos9s/swap deve ter +512 MiB (total ~2,5 GiB); corre: sudo lvs centos9s/swap -o lv_size"
  lab_ssh "${VM}" 'sudo lvs centos9s/swap -o lv_name,lv_size 2>/dev/null' | sed 's/^/    /' || true
  FAIL=$((FAIL + 1))
fi

# swapon pode mostrar /dev/dm-N em vez do nome mapper
assert_ssh "${VM}" 'test "$(swapon --show --noheadings 2>/dev/null | wc -l)" -gt 0' \
  'swap ativo (swapon --show)'

if lab_ssh "${VM}" 'awk "NR>1 {s+=\$3} END {exit (s+0 >= '"${MIN_SWAP_KB}"') ? 0 : 1}" /proc/swaps 2>/dev/null'; then
  echo "OK: memória swap ativa (~2,5 GiB em /proc/swaps)"
  PASS=$((PASS + 1))
else
  echo "FAIL: swap ativo mas tamanho em /proc/swaps abaixo do esperado (~2,5 GiB)"
  lab_ssh "${VM}" 'cat /proc/swaps; free -h | grep -i swap' | sed 's/^/    /' || true
  FAIL=$((FAIL + 1))
fi

assert_ssh "${VM}" 'grep -qiE "swap|centos9s-swap" /etc/fstab' \
  'entrada de swap em /etc/fstab'

# Não exigir datastore; se existir (ex. 07), só avisa se vdb estiver no VG errado
if lab_ssh "${VM}" 'sudo pvs --noheadings -o pv_name,vg_name 2>/dev/null | grep -q "/dev/vdb.*datastore"'; then
  echo "WARN: /dev/vdb está no VG datastore — deveria estar em centos9s para este exercício"
fi

finish_validation "${EXERCISE}"
