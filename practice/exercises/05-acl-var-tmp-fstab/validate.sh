#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server1
EXERCISE=05-acl-var-tmp-fstab

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'test -f /var/tmp/fstab' 'ficheiro /var/tmp/fstab existe'

assert_ssh "${VM}" 'stat -c "%U:%G" /var/tmp/fstab | grep -qx root:root' 'owner root:root'

assert_ssh "${VM}" '[ -x /var/tmp/fstab ] && exit 1 || exit 0' 'ficheiro não é executável'

assert_ssh "${VM}" 'getfacl /var/tmp/fstab 2>/dev/null | grep -q "user:natasha:rw"' \
  'ACL permite natasha ler/escrever'

assert_ssh "${VM}" 'getfacl /var/tmp/fstab 2>/dev/null | grep -q "user:harry:---"' \
  'ACL nega harry'

assert_ssh "${VM}" 'sudo -u natasha cat /var/tmp/fstab >/dev/null' 'natasha consegue ler'

assert_ssh_not "${VM}" 'sudo -u harry cat /var/tmp/fstab >/dev/null' 'harry não consegue ler'

finish_validation "${EXERCISE}"
