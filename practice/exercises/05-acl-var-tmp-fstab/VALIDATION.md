# Validação — Exercise 05

## Critérios

- Ficheiro `/var/tmp/fstab` existe.
- Dono `root:root`, sem bit de execução.
- ACL: `natasha` rw, `harry` sem acesso, máscara/other read para restantes (conforme enunciado).

## Exemplo de solução (estuda depois de tentar)

```bash
cp /etc/fstab /var/tmp/fstab
chmod 644 /var/tmp/fstab
setfacl -m u:natasha:rw-,u:harry:--- /var/tmp/fstab
# default ACL para novos users: só leitura — ajusta conforme enunciado
```

## Ver manual

```bash
getfacl /var/tmp/fstab
sudo -u natasha cat /var/tmp/fstab
sudo -u harry cat /var/tmp/fstab   # deve falhar
```
