# Validação — Exercise 06

## Critérios

- `httpd` enabled e active
- Porta 82 permitida em SELinux (`semanage port -l | grep http_port_t | grep 82`)
- Contexto de `file1` adequado (`httpd_sys_content_t`)
- `curl` local à porta 82 funciona

## Pacotes

Se `semanage` faltar, instala com repo do lab (exercise 01): `policycoreutils-python-utils`, `httpd`.

## Listen port 82

```bash
echo 'Listen 82' > /etc/httpd/conf.d/listen82.conf
# ou edita config conforme versão httpd
```

## Consolidar

- `restorecon -Rv /var/www/html/file1`
- `semanage port -a -t http_port_t -p tcp 82`
- `ausearch -m avc -ts recent` para diagnosticar
