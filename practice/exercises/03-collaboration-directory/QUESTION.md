# Exercise 03 — Create a collaboration directory

**Target:** `server1`  
**Reference:** EX200 sample Q6  
**Requires:** Exercise 02 (`sysmgrs`, users)

## Task

Create **`/home/managers`** with these characteristics:

- Group ownership (owning group) is **`sysmgrs`**.
- The directory is **readable, writable, and accessible** by members of **`sysmgrs`** only (not by other users). Root may always access everything.
- **New files** created in `/home/managers` automatically inherit group **`sysmgrs`** (correct special permission).

Verify by creating a test file as user **`natasha`** and confirming group ownership.

When finished: `./scripts/lab-practice.sh validate 03`
