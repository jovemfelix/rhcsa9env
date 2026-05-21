# Validação — Exercise 04

## Critérios

- `systemctl is-active crond` → active
- `crontab -u natasha -l` contém `EX200 in progress` e intervalo de 2 minutos (`*/2`)
- Mensagens no log (messages ou journal) — opcional no script se ainda não passou 2 min

## Se falhar

```bash
systemctl enable --now crond
crontab -u natasha -e
# */2 * * * * logger "EX200 in progress"
```

## Consolidar

- Cron de utilizador ≠ `/etc/cron.d/` — usa `crontab -u natasha -e`.
- RHEL 9: logs podem estar em `journalctl`, não só `/var/log/messages`.
