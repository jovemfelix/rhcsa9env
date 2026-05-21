# Exercise 01 — Configure the system to use the lab repository

**Target:** `server1` (`server1.nine.example.com`, `192.168.55.150`)  
**Reference:** EX200 sample Q2 (repository configuration)

## Task

Your system currently has **no** YUM/DNF repository configuration suitable for installing packages.

Configure **server1** to use the lab repository as its software source:

| Repository | Base URL |
|------------|----------|
| BaseOS | `http://repo/BaseOS` |
| AppStream | `http://repo/AppStream` |

Requirements:

- Create repository definition(s) under `/etc/yum.repos.d/`.
- Repositories must be **enabled**.
- **GPG checking must be disabled** (`gpgcheck=0`) for this lab mirror.
- You must be able to run `dnf repolist` successfully and see both repositories.
- Install the package `yum-utils` (or `dnf-plugins-core` if already present) using only these repositories.

Do **not** modify the **repo** VM for this task.

## Hints (exam-style, optional)

- Short name `repo` resolves via `/etc/hosts`.
- Use `dnf` / `yum`; RHEL 9 uses DNF by default.

When finished, validate: `./scripts/lab-practice.sh validate 01`
