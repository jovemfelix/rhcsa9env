# Exercise 09 — Extend swap logical volume (server2, CLI)

**Target:** `server2` (`server2.nine.example.com`, `192.168.55.151`)  
**Reference:** EX200 objective — create/configure LVM; add and extend swap  
**Tool:** **Terminal only** (`pvcreate`, `vgextend`, `lvextend`, `mkswap`, `swapon`)

---

## Your starting point (lab)

Typical layout:

```text
vda  → centos9s VG (root ~125 GiB + swap 2 GiB)   ← you extend swap here
vdb  → whole-disk ext4 → /extradisk1             ← you will reuse this disk as PV
vdc  → Exercise 07 (datastore / database)        ← do NOT change for this task
```

Check:

```bash
lsblk
sudo vgs
sudo lvs centos9s
free -h
swapon --show
```

The volume group **`centos9s`** usually has **no free extents** until you add a new physical volume.  
Swap today is logical volume **`swap`** (device **`/dev/centos9s/swap`** or **`/dev/mapper/centos9s-swap`**) at about **2 GiB**.

---

## Goal (what “done” looks like)

| Step | Result |
|------|--------|
| 1 | **`/dev/vdb`** is a PV and member of VG **`centos9s`** (no `/extradisk1` mount) |
| 2 | LV **`swap`** in **`centos9s`** is **512 MiB larger** than before → about **2.5 GiB** total |
| 3 | Swap is **active** after reboot (`/etc/fstab` still correct) |

Do **not** resize **`root`**, **`vda`**, or anything on **`vdc`** / **`datastore`**.

---

## Suggested workflow (exam-style)

Work as **root** (`sudo -i`) on **server2**.

### Step A — Free `/dev/vdb`

1. Unmount the lab mount:

   ```bash
   sudo umount /extradisk1
   ```

2. Remove the **`extradisk1`** line from **`/etc/fstab`**.

3. Wipe filesystem signatures on **`/dev/vdb`** only:

   ```bash
   sudo wipefs -a /dev/vdb
   ```

   Confirm: `lsblk` shows **`vdb` with no MOUNTPOINT**.

### Step B — Add space to volume group `centos9s`

4. Create a physical volume on the whole disk:

   ```bash
   sudo pvcreate /dev/vdb
   ```

5. Extend the existing system volume group:

   ```bash
   sudo vgextend centos9s /dev/vdb
   ```

   Verify: `sudo vgs centos9s` shows **Free PE** > 0.

### Step C — Extend the swap logical volume

6. Turn off swap on the LV you are resizing:

   ```bash
   sudo swapoff /dev/centos9s/swap
   ```

7. Grow the swap LV by **exactly 512 MiB**:

   ```bash
   sudo lvextend -L +512M /dev/centos9s/swap
   ```

   Alternative (same size with 4 MiB extents): `sudo lvextend -l +128 /dev/centos9s/swap`

8. Recreate swap signature on the enlarged LV:

   ```bash
   sudo mkswap /dev/centos9s/swap
   ```

9. Activate swap:

   ```bash
   sudo swapon /dev/centos9s/swap
   ```

### Step D — Persistent swap (`/etc/fstab`)

10. **`mkswap` changes the UUID.** Update **`/etc/fstab`** so the swap line matches the current device or UUID:

    ```bash
    sudo blkid /dev/centos9s/swap
    ```

    Example (use your UUID):

    ```fstab
    UUID=<uuid>  none  swap  defaults  0 0
    ```

    Or keep the mapper name if already present:

    ```fstab
    /dev/mapper/centos9s-swap  none  swap  defaults  0 0
    ```

11. Test persistence:

    ```bash
    sudo swapoff /dev/centos9s/swap
    sudo swapon -a
    free -h
    swapon --show
    ```

---

## Verification commands

```bash
sudo pvs | grep -E 'vdb|centos9s'
sudo vgs centos9s
sudo lvs centos9s/swap -o lv_name,lv_size
free -h
grep -i swap /etc/fstab
```

Expected: swap about **2.5 GiB**, **`/dev/vdb`** in VG **`centos9s`**.

---

## What you must NOT do

- Do **not** use Cockpit or other GUI for this exercise.
- Do **not** `lvextend` while swap is still enabled (always **`swapoff`** first).
- Do **not** skip **`mkswap`** after growing a swap LV.
- Do **not** modify **`vdc`** or volume group **`datastore`** (Exercise 07).

---

## Validate

From the project directory on your Fedora host:

```bash
./scripts/lab-practice.sh validate 09
```

Validation feedback is in Portuguese in `VALIDATION.md`.
