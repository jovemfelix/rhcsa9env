# Exercise 05 — ACL on /var/tmp/fstab

**Target:** `server1`  
**Reference:** EX200 sample Q9  
**Requires:** Exercise 02 (`natasha`, `harry`)

## Task

1. Copy **`/etc/fstab`** to **`/var/tmp/fstab`**.

Configure permissions on **`/var/tmp/fstab`** so that:

| Requirement | Detail |
|-------------|--------|
| Owner | `root` |
| Group | `root` |
| Execute bit | Not executable by anyone |
| **natasha** | May read and write |
| **harry** | Cannot read or write |
| **All other users** | May read only |

Use **ACL** (`setfacl` / `getfacl`). Base mode bits alone are not sufficient for the exam-style grading.

When finished: `./scripts/lab-practice.sh validate 05`
