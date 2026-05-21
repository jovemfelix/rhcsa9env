# Exercise 06 — SELinux: httpd on port 82

**Target:** `server1`  
**Reference:** EX200 sample Q3

## Scenario (preparation)

On **server1**, prepare a broken web setup (as root):

```bash
echo 'exam file 1' > /var/www/html/file1
echo 'exam file 2' > /var/www/html/file2
chcon -t default_t /var/www/html/file1
semanage port -d -t http_port_t -p tcp 82 2>/dev/null || true
```

Configure **httpd** to listen on **port 82** and ensure the service is **enabled**.

## Task

Fix SELinux and service issues so that:

- Existing HTML files under **`/var/www/html`** remain (do not delete exam content).
- **`httpd`** serves content on **port 82**.
- **`httpd`** starts automatically at boot.
- `curl http://localhost:82/file1` returns the page content.

Do not set SELinux to permissive or disabled.

When finished: `./scripts/lab-practice.sh validate 06`
