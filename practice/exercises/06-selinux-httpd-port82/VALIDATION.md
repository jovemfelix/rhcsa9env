# Validação — Exercise 06

## Critérios

- `httpd` enabled e active
- Porta 82 permitida em SELinux (`semanage port -l | grep http_port_t | grep 82`)
- Contexto de `file1` adequado (`httpd_sys_content_t`)
- `curl` local à porta 82 funciona

## Pacotes (`semanage` not found)

O binário vem do RPM **`policycoreutils-python-utils`** (AppStream). O mirror do lab pode não tê-lo até atualizares o **repo**.

**No server1** (com repos `http://repo/...` configurados, exercise 01):

```bash
sudo dnf install -y policycoreutils-python-utils
sudo semanage --help
```

Se `No match for argument`:

1. No **host**, atualiza o mirror no repo e repodata:

```bash
vagrant ssh repo -c 'sudo dnf download --resolve --destdir /var/www/html/AppStream/appstream/Packages policycoreutils-python-utils && sudo createrepo_c --update /var/www/html/AppStream/appstream'
```

2. No **server1**:

```bash
sudo dnf clean all
sudo dnf install -y policycoreutils-python-utils
```

Também úteis: `setroubleshoot-server` (diagnóstico), `httpd` (já no lab).

## Listen port 82

```bash
echo 'Listen 82' > /etc/httpd/conf.d/listen82.conf
# ou edita config conforme versão httpd
```

## Consolidar

- `restorecon -Rv /var/www/html/file1`
- `semanage port -a -t http_port_t -p tcp 82`
- `ausearch -m avc -ts recent` para diagnosticar
