# Exercise 07 — Logical volume on server2

**Target:** `server2` (`192.168.55.151`)  
**Reference:** EX200 sample Q15 (adapted)

## Task

On **server2**, use disk **`/dev/vdc`** (16 GiB) for LVM. You may remove the existing `/extradisk2` mount on `vdc` if it was created by the lab provisioner.

Create:

| Item | Value |
|------|--------|
| Volume group | **`datastore`** |
| Physical extent size | **16 MiB** |
| Logical volume | **`database`**, size **60** extents |
| Filesystem | **ext4** |
| Mount point | **`/mnt/database`** |
| Persistence | Mount automatically at boot (`/etc/fstab`) |

Requirements:

- `vgs` shows **`datastore`** with 16 MiB PE size.
- `lvs` shows **`database`** in **`datastore`**.
- `df -h` shows `/mnt/database` mounted.

When finished: `./scripts/lab-practice.sh validate 07`
