#!/usr/bin/env bash
# Extra disks: libvirt (virtio vdb/vdc) or VirtualBox (SATA sdb/sdc)
set -euo pipefail

wait_for_block() {
  local dev=$1
  local n=0
  while [[ ! -b "${dev}" ]] && [[ ${n} -lt 30 ]]; do
    sleep 2
    n=$((n + 1))
    partprobe 2>/dev/null || true
    udevadm settle 2>/dev/null || true
  done
  [[ -b "${dev}" ]]
}

format_disk() {
  local dev=$1
  local label=$2
  if blkid -L "${label}" >/dev/null 2>&1; then
    echo "Disk ${label} already formatted"
    return 0
  fi
  # -F avoids prompts; do not use "yes | mkfs" (breaks with pipefail)
  mkfs.ext4 -F -L "${label}" "${dev}"
  udevadm settle 2>/dev/null || true
}

mount_disk() {
  local label=$1
  local mnt=$2
  mkdir -p "${mnt}"
  grep -q "LABEL=${label}" /etc/fstab || \
    echo "LABEL=${label} ${mnt} ext4 defaults 0 0" >> /etc/fstab
  if ! mountpoint -q "${mnt}"; then
    mount "LABEL=${label}" "${mnt}"
  fi
}

if [[ -b /dev/vdb && -b /dev/vdc ]]; then
  D1=/dev/vdb
  D2=/dev/vdc
elif [[ -b /dev/sdb && -b /dev/sdc ]]; then
  D1=/dev/sdb
  D2=/dev/sdc
else
  echo "ERROR: extra disks not found (expected vdb+vdc or sdb+sdc)" >&2
  lsblk >&2 || true
  exit 1
fi

wait_for_block "${D1}"
wait_for_block "${D2}"

format_disk "${D1}" extradisk1
mount_disk extradisk1 /extradisk1

format_disk "${D2}" extradisk2
mount_disk extradisk2 /extradisk2

echo "Extra disks ready: $(lsblk -o NAME,SIZE,LABEL,MOUNTPOINT ${D1} ${D2})"
