# Validação — Exercise 09 (estender swap LVM, português)

## O que o enunciado pede (resumo)

1. Libertar **`/dev/vdb`** (desmontar `/extradisk1`, limpar `fstab`, `wipefs`).
2. **`pvcreate /dev/vdb`** + **`vgextend centos9s /dev/vdb`**.
3. **`swapoff`** → **`lvextend -L +512M`** em **`centos9s/swap`** → **`mkswap`** → **`swapon`**.
4. Ajustar **`/etc/fstab`** se o UUID do swap mudou.
5. Swap total ≈ **2,5 GiB**; **`vdc` / datastore** intactos.

---

## Sequência correta (swap LV)

Ordem típica no exame:

```bash
sudo swapoff /dev/centos9s/swap
sudo lvextend -L +512M /dev/centos9s/swap
sudo mkswap /dev/centos9s/swap
sudo swapon /dev/centos9s/swap
```

**Erro comum:** `lvextend` com swap ainda ativo, ou esquecer `mkswap` depois de aumentar o LV.

---

## Erros comuns

| Sintoma | Causa |
|---------|--------|
| `vgextend` sem espaço livre antes | Falta `pvcreate` + `vgextend` em `vdb` |
| `lvextend` falha | VG `centos9s` ainda sem free PE |
| Swap não aumenta no `free -h` | Falta `mkswap` / `swapon` após `lvextend` |
| `swapon -a` falha no reboot | UUID antigo no `fstab` após `mkswap` |
| `validate` falha em `vdb` PV | `vdb` ainda montado em `/extradisk1` |
| Partiu o exercício 07 | Mexeste em `vdc` / `datastore` (não deves) |

---

## O que o script `validate.sh` verifica

1. **`/extradisk1`** desmontado
2. **`/dev/vdb`** é PV no VG **`centos9s`**
3. LV **`swap`** com tamanho ≥ **2,5 GiB**
4. Swap **ativo** (`swapon`) no dispositivo `centos9s-swap`
5. Entrada **swap** em **`/etc/fstab`**

```bash
./scripts/lab-practice.sh validate 09
```

---

## Repor só este exercício

```bash
./scripts/lab-practice.sh reset 09-extend-swap-lvm-server2
```

Reverte swap para **2 GiB**, remove `vdb` do VG `centos9s` e repõe **`/extradisk1`** (ext4). Não apaga o LVM do exercício 07 em `vdc`.
