# Validação — Exercise 07

## Critérios automáticos

- VG `datastore` com PE 16M
- LV `datastore/database` presente
- Montado em `/mnt/database` tipo ext4
- Entrada em `/etc/fstab` para o LV

## Se falhar

```bash
# exemplo de fluxo (adapta se vdc tiver partições antigas)
umount /extradisk2 2>/dev/null; wipefs -a /dev/vdc
pvcreate /dev/vdc
vgcreate -s 16M datastore /dev/vdc
lvcreate -l 60 -n database datastore
mkfs.ext4 /dev/datastore/database
mkdir -p /mnt/database
blkid   # UUID para fstab
```

## Nota

No sample exam, PE count and disk names differ — foca nos **comandos** (`vgcreate -s`, `lvcreate -l`, `fstab` com UUID).
