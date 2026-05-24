# RHCSA EX200 — prática guiada (lab nine.example.com)

Exercícios inspirados em [RHCSA-EX200 sample questions](https://github.com/Abdulhamid97Mousa/RHCSA-EX200/blob/main/EX200-Exam-Questions/README.md) e objetivos **RHEL 9 / EX200**, adaptados ao teu ambiente (`server1`, `server2`, `repo`).

## Como usar

1. **Enunciado em inglês** — ficheiro `QUESTION.md` em cada pasta (como no exame).
2. **Executas na VM** indicada (`server1` ou `server2`) com `sudo` / `root`.
3. **Validas** quando achares que terminaste:

```bash
./scripts/lab-practice.sh list
./scripts/lab-practice.sh validate 01-yum-repo-client
# ou, dentro da pasta do exercício:
./practice/exercises/01-yum-repo-client/validate.sh
```

4. **Feedback** — o script imprime `OK` / `FAIL` (mensagens em **português**). Detalhes em `VALIDATION.md`.
5. **Recomeçar** um exercício: `./scripts/lab-practice.sh reset 02-users-groups` (só apaga artefactos desse exercício) ou `./scripts/lab-reset.sh` (reset completo do lab).

## Mapa do lab (não é o enunciado do sample exam)

| Papel | Hostname | IP (eth1) | VM Vagrant |
|--------|----------|-----------|------------|
| Repo | `repo.nine.example.com` | 192.168.55.149 | `repo` |
| Server A | `server1.nine.example.com` | 192.168.55.150 | `server1` |
| Server B | `server2.nine.example.com` | 192.168.55.151 | `server2` |

URLs do repositório offline (como no exame, nomes curtos em `/etc/hosts`):

- `http://repo/BaseOS`
- `http://repo/AppStream`

Ver também [LAB-CONTEXT.md](LAB-CONTEXT.md).

## Índice de exercícios

| ID | Pasta | VM | Tema (EX200) | Depende de |
|----|-------|-----|--------------|------------|
| 01 | `01-yum-repo-client` | server1 | YUM/DNF repository | — |
| 02 | `02-users-groups` | server1 | Users / groups | — |
| 03 | `03-collaboration-directory` | server1 | Setgid directory | 02 |
| 04 | `04-cron-natasha` | server1 | cron | 02 |
| 05 | `05-acl-var-tmp-fstab` | server1 | ACL | 02 |
| 06 | `06-selinux-httpd-port82` | server1 | SELinux + httpd | 01 (repo) |
| 07 | `07-lvm-database-server2` | server2 | LVM em **/dev/vdc** (substitui `/extradisk2` por `/mnt/database`) | — |
| 08 | `08-secondary-ip-server2` | server2 | nmcli / IP secundário | — |
| 09 | `09-extend-swap-lvm-server2` | server2 | Estender LV **swap** em **centos9s** com **vdb** (CLI: `vgextend`, `lvextend`, `mkswap`) | — |

Ordem sugerida: **01 → 02 → 03 → 04 → 05 → 06**, depois **07 → 09 → 08** (ou **07 → 08 → 09**) em server2.

## Modo “pergunta → validação” (com o assistente / estudo)

1. Abre só o `QUESTION.md` (não leias `VALIDATION.md` antes de tentar).
2. Implementa na VM.
3. Corre `validate.sh` ou pede ao assistente: *“valida o exercício 02”* — a validação pode ser explicada em português.
4. Se falhar, lê `VALIDATION.md` (dicas) e corrige; volta a validar.

## Referências

- [Abdulhamid97Mousa/RHCSA-EX200](https://github.com/Abdulhamid97Mousa/RHCSA-EX200)
- Documentação Red Hat: [RHCSA EX200](https://www.redhat.com/en/services/training/ex200-red-hat-certified-system-administrator-rhcsa-exam)
