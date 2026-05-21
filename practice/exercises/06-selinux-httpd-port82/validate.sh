#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server1
EXERCISE=06-selinux-httpd-port82

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'systemctl is-enabled httpd' 'httpd enabled no boot'

assert_ssh "${VM}" 'systemctl is-active httpd' 'httpd active'

assert_ssh "${VM}" 'sudo semanage port -l 2>/dev/null | grep http_port_t | grep -q "\<82\>"' \
  'porta 82 permitida em SELinux (http_port_t)'

assert_ssh "${VM}" 'test -f /var/www/html/file1' 'ficheiro file1 existe'

assert_ssh "${VM}" 'ls -Z /var/www/html/file1 2>/dev/null | grep -q httpd_sys_content_t' \
  'SELinux context de file1 é httpd_sys_content_t'

assert_ssh "${VM}" 'curl -sf http://127.0.0.1:82/file1 | grep -q "exam file 1"' \
  'httpd responde na porta 82 com conteúdo de file1'

finish_validation "${EXERCISE}"
