# Validação — Exercise 03

## Critérios

- Diretório `/home/managers` existe.
- Grupo: `sysmgrs` (ex.: `drwxrws---` root:sysmgrs).
- Bit **setgid** (`g+s`) — aparece `s` no grupo em `ls -ld`.
- Outros sem permissão (`o---` ou `---` na parte other).
- Ficheiro criado por `natasha` no diretório tem grupo `sysmgrs`.

## Se falhar

```bash
chown root:sysmgrs /home/managers
chmod 2770 /home/managers   # ou: chmod g+rwx,o=--- + chmod g+s
```

## Reset

`./scripts/lab-practice.sh reset 03-collaboration-directory`
