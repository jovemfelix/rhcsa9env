# Exercise 02 — Create user accounts and a group

**Target:** `server1`  
**Reference:** EX200 sample Q4

## Task

Create the following users, groups, and memberships:

- A group named **`sysmgrs`**.
- User **`natasha`**, with **`sysmgrs`** as a **secondary** group.
- User **`harry`**, with **`sysmgrs`** as a **secondary** group.
- User **`sarah`**, who must **not** have access to an interactive shell and must **not** be a member of **`sysmgrs`**.
- Passwords for **natasha**, **harry**, and **sarah** must all be **`password`**.

Requirements:

- Users can be verified with `id` and `getent`.
- `sarah` must not obtain a normal login shell (use `/sbin/nologin` or equivalent).

When finished: `./scripts/lab-practice.sh validate 02`
