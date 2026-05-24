# Validação — Exercise 04

## Critérios

- `systemctl is-active crond` → active
- `crontab -u natasha -l` contém `EX200 in progress` e intervalo de 2 minutos (`*/2`)
- Mensagens no log (messages ou journal) — opcional no script se ainda não passou 2 min

## Se falhar

```bash
sudo systemctl enable --now crond
sudo crontab -u natasha -e
sudo crontab -u natasha -l
# */2 * * * * logger "EX200 in progress"
```

**Nota:** `crontab -u` exige **root** (usa `sudo`). O `validate.sh` também usa `sudo`, porque `vagrant ssh` entra como `vagrant`.

## Consolidar

- Cron de utilizador ≠ `/etc/cron.d/` — usa `crontab -u natasha -e`.
- RHEL 9: logs podem estar em `journalctl`, não só `/var/log/messages`.
