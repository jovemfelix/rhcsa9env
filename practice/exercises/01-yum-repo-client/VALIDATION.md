# Validação — Exercise 01 (português)

## O que o script verifica

1. Existe pelo menos um ficheiro `.repo` em `/etc/yum.repos.d/`.
2. Os URLs contêm `repo` e `BaseOS` / `AppStream`.
3. `dnf repolist` corre sem erro e lista repositórios.
4. O pacote `yum-utils` ou `dnf-plugins-core` está instalado.

## Se falhar

| Sintoma | Provável causa |
|---------|----------------|
| `Cannot download repomd.xml` | Repo VM parada ou mirror — `vagrant up repo`, `./scripts/lab-health.sh` |
| `Could not resolve host: repo` | `/etc/hosts` — confirma linha `192.168.55.149 ... repo` |
| `gpgcheck` errors | Define `gpgcheck=0` em cada secção `[...]` |
| Repositório disabled | `enabled=1` |

## Comandos manuais (tu)

```bash
vagrant ssh server1
sudo dnf repolist
sudo cat /etc/yum.repos.d/*.repo
curl -sI http://repo/BaseOS/repodata/repomd.xml
```

## Consolidar

- Um ficheiro com duas secções `[baseos]` + `[appstream]` ou dois ficheiros `.repo` — ambos válidos.
- No exame, o hostname do repo é outro; aqui usas `http://repo/...` conforme [LAB-CONTEXT.md](../../LAB-CONTEXT.md).
