# Exercise 04 — Configure a cron job

**Target:** `server1`  
**Reference:** EX200 sample Q5  
**Requires:** Exercise 02 (user `natasha`)

## Task

Configure a **cron job** that:

- Runs **every 2 minutes**.
- Executes: `logger "EX200 in progress"`
- Runs as user **`natasha`**.

Requirements:

- The **`crond`** service is enabled and running.
- The job is visible in `crontab -u natasha -l`.

When finished: `./scripts/lab-practice.sh validate 04`

> Note: validation may need up to 2 minutes to see log lines in `/var/log/messages` or the journal.
