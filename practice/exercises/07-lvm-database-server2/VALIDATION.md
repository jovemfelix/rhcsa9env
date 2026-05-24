# Validação — Exercise 07 (detalhado, português)

## O que o enunciado pede (resumo)

Hoje o **`/dev/vdc`** está formatado como um **ext4 inteiro** e montado em **`/extradisk2`** (script do Vagrant). O exercício pede para **apagar esse uso** e criar, no **mesmo disco**:

```
/dev/vdc  →  PV  →  VG datastore (PE 16 MiB)  →  LV database (60 PE)  →  ext4  →  /mnt/database + fstab
```

O disco **`/dev/vdb`** (`/extradisk1`) **não entra** neste exercício — deixa como está.

---

## Estado atual vs estado alvo

| Disco | Agora (lab) | Depois (exercício 07) |
|-------|-------------|------------------------|
| `vda` | SO (boot, `/`, swap) | Igual — **não mexer** |
| `vdb` | ext4 → `/extradisk1` | Igual — **não mexer** |
| `vdc` | ext4 → `/extradisk2` | LVM → `/mnt/database` |

Se no fim ainda vires `vdc` com `MOUNTPOINT /extradisk2`, o exercício **não** está concluído.

---

## Passo a passo (consolidar)

### 1. Libertar o `vdc`

```bash
sudo umount /extradisk2
sudo sed -i '/extradisk2/d' /etc/fstab    # ou edita à mão
sudo wipefs -a /dev/vdc
lsblk    # vdc sem MOUNTPOINT
```

### 2. LVM

```bash
sudo pvcreate /dev/vdc
sudo vgcreate -s 16M datastore /dev/vdc
sudo lvcreate -l 60 -n database datastore
sudo pvs && sudo vgs datastore && sudo lvs datastore
```

`-s 16M` = physical extent de **16 MiB** (como no enunciado).  
`-l 60` = **60 extents**, não 60 MiB.

### 3. Sistema de ficheiros e montagem permanente

```bash
sudo mkfs.ext4 /dev/datastore/database
sudo mkdir -p /mnt/database
UUID=$(sudo blkid -s UUID -o value /dev/datastore/database)
echo "UUID=${UUID}  /mnt/database  ext4  defaults  0 0" | sudo tee -a /etc/fstab
sudo mount -a
df -h /mnt/database
```

### 4. Erros comuns

| Erro | Causa |
|------|--------|
| `pvcreate` falha, disco em uso | Falta `umount /extradisk2` |
| `vgcreate` PE errado | Usaste `-s 16` sem `M` ou outro tamanho |
| LV demasiado grande | `-l 60` são **extents**, não MB |
| `mount -a` falha | UUID errado no `fstab` ou falta `mkfs` |
| Validação falha `vgs` | Comandos LVM precisam de **`sudo`** (como no exame como root) |
| `lvs datastore/database` falha mas `lvs` mostra LV `datastore` | Criaste o LV com **nome errado** (igual ao VG). Ver secção abaixo. |

### 5. Confusão VG `datastore` vs LV `database` (muito comum)

O enunciado pede:

| Objeto | Nome |
|--------|------|
| Volume group | `datastore` |
| Logical volume | **`database`** (outro nome) |

Se correste algo como `lvcreate -l 60 -n datastore datastore`, o LVM cria um LV chamado **`datastore`**:

```text
/dev/mapper/datastore-datastore   # errado para o enunciado
```

O correto:

```text
sudo lvcreate -l 60 -n database datastore
/dev/mapper/datastore-database
```

**Correção sem refazer tudo** (já tens 960 MiB e ext4):

```bash
sudo umount /mnt/database
sudo lvrename datastore datastore database
sudo blkid /dev/datastore/database
# Ajusta /etc/fstab se o UUID ou device mudou
sudo mount -a
sudo lvs datastore
```

`lvs datastore/database` só funciona quando o **LV** se chama `database` (sintaxe `VG/LV`).

---

## O que o script `validate.sh` verifica

1. Existe VG **`datastore`** com extent **16M**
2. Existe LV **`database`**
3. **`/mnt/database`** montado com **ext4**
4. Linha em **`/etc/fstab`** com `/mnt/database`

Corre no host:

```bash
./scripts/lab-practice.sh validate 07
```

---

## Repor só este exercício

```bash
./scripts/lab-practice.sh reset 07-lvm-database-server2
```

Isto remove LV/VG/PV em `vdc` e volta a formatar `extradisk2` **não** — após reset tens de repetir o exercício ou o provisioner de discos (`vagrant provision server2`) se quiseres `/extradisk2` outra vez.

---

## Relação com o sample EX200

O [sample Q15](https://github.com/Abdulhamid97Mousa/RHCSA-EX200/blob/main/EX200-Exam-Questions/README.md) usa outro disco e **ext3**; aqui usamos **`vdc`**, **ext4** e mount **`/mnt/database`** — a **sequência** (`pvcreate` → `vgcreate -s` → `lvcreate -l` → `mkfs` → `fstab`) é o que importa para o exame.
