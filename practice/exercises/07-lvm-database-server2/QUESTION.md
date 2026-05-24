# Exercise 07 — Logical volume on server2

**Target:** `server2` (`server2.nine.example.com`, `192.168.55.151`)  
**Reference:** EX200 sample Q15 (create LVM, format, persistent mount)  
**Disk to use:** **`/dev/vdc` only** — leave **`/dev/vda`** (OS) and **`/dev/vdb`** (`/extradisk1`) unchanged.

---

## Your starting point (lab provisioner)

After `vagrant up server2`, you typically see:

```text
vda   → OS disk (boot + LVM root + swap)     DO NOT MODIFY
vdb   → 16 GiB, mounted as /extradisk1       LEAVE AS-IS for this exercise
vdc   → 16 GiB, mounted as /extradisk2       YOU WILL REUSE THIS DISK FOR LVM
```

Example:

```bash
[vagrant@server2 ~]$ lsblk
NAME              SIZE TYPE MOUNTPOINTS
vda               128G disk
├─vda1              1G part /boot
└─vda2            127G part
  ├─centos9s-root 125G lvm  /
  └─centos9s-swap   2G lvm  [SWAP]
vdb                16G disk /extradisk1
vdc                16G disk /extradisk2
```

**Important:** `vdc` is **not empty** today — it is a whole-disk **ext4** filesystem (`extradisk2`).  
For this task you must **stop using it as `/extradisk2`** and turn **`/dev/vdc`** into an LVM physical volume.

---

## Goal (what “done” looks like)

| Layer | What you must have |
|--------|---------------------|
| Physical volume | **`/dev/vdc`** is a PV (no `/extradisk2` mount) |
| Volume group | Name **`datastore`**, extent size **16 MiB** |
| Logical volume | Name **`database`**, size **60 extents** (60 × 16 MiB ≈ 960 MiB) |
| Filesystem | **ext4** on `/dev/datastore/database` |
| Mount | **`/mnt/database`**, mounted and listed in **`/etc/fstab`** (survives reboot) |

Conceptual result:

```text
vdc  → PV → VG datastore → LV database → ext4 → /mnt/database
```

Commands to verify when finished:

```bash
sudo pvs
sudo vgs datastore
sudo lvs datastore
df -h /mnt/database
grep database /etc/fstab
```

---

## Suggested workflow (exam-style)

Work as **root** (`sudo -i`) on **server2**.

### Step A — Free `/dev/vdc`

1. Unmount the lab mount (if present):

   ```bash
   sudo umount /extradisk2
   ```

2. Remove the **`extradisk2`** line from `/etc/fstab` (otherwise boot may fail or wait).

3. Wipe old filesystem signatures on **`/dev/vdc`** only:

   ```bash
   sudo wipefs -a /dev/vdc
   ```

   Confirm: `lsblk` shows **`vdc` with no MOUNTPOINT**.

### Step B — Create LVM stack

4. Physical volume on the **whole disk** `vdc`:

   ```bash
   sudo pvcreate /dev/vdc
   ```

5. Volume group with **16 MiB** physical extents:

   ```bash
   sudo vgcreate -s 16M datastore /dev/vdc
   ```

6. Logical volume **60** extents named **`database`** (not the same name as the VG):

   ```bash
   sudo lvcreate -l 60 -n database datastore
   ```

   **Common mistake:** `lvcreate -n datastore ...` creates LV **`datastore`** → device `/dev/mapper/datastore-datastore`.  
   The task requires LV name **`database`** → `/dev/datastore/database` or `/dev/mapper/datastore-database`.

   Check with: `sudo lvs datastore` — the **LV** column must show `database`.

### Step C — Filesystem and persistent mount

7. Format and mount:

   ```bash
   sudo mkfs.ext4 /dev/datastore/database
   sudo mkdir -p /mnt/database
   sudo mount /dev/datastore/database /mnt/database
   ```

8. Add **`/etc/fstab`** entry using **UUID** (recommended on exam):

   ```bash
   sudo blkid /dev/datastore/database
   ```

   Example line (use your UUID):

   ```fstab
   UUID=<uuid>  /mnt/database  ext4  defaults  0 0
   ```

9. Test persistence:

   ```bash
   sudo umount /mnt/database
   sudo mount -a
   df -h /mnt/database
   ```

---

## What you must NOT do

- Do **not** repartition or remove **`vda`** (system disk).
- Do **not** use **`vdb`** for this exercise (keep `/extradisk1` unless you choose to redo lab disks yourself).
- Do **not** set SELinux to permissive; not required here.

---

## Size check (why 60 extents fits)

- Physical extent size: **16 MiB**
- LV size: **60 extents** → about **960 MiB**
- Disk **vdc**: **16 GiB** → plenty of free space in the VG for 60 extents

---

## Validate

From the project directory on your Fedora host:

```bash
./scripts/lab-practice.sh validate 07
```

Validation feedback is in Portuguese in `VALIDATION.md`.
