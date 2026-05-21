# Validação — Exercise 02

## Critérios

- Grupo `sysmgrs` existe.
- `natasha` e `harry` têm `sysmgrs` nos grupos suplementares.
- `sarah` existe, shell é `nologin`, não está em `sysmgrs`.
- Contas locais presentes em `/etc/passwd`.

## Se falhar

- **Grupo secundário:** `useradd -G sysmgrs` ou `usermod -aG sysmgrs`.
- **Senha no RHEL 9:** `echo 'user:password' | chpasswd` (não uses `passwd --stdin`).
- **sarah:** `useradd -s /sbin/nologin sarah` — sem `-G sysmgrs`.

## Verificação manual

```bash
getent group sysmgrs
id natasha
id harry
getent passwd sarah
```

## Reset deste exercício

`./scripts/lab-practice.sh reset 02-users-groups`
