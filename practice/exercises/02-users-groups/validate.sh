#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server1
EXERCISE=02-users-groups

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'getent group sysmgrs' 'grupo sysmgrs existe'

assert_ssh "${VM}" 'id natasha | grep -q sysmgrs' 'natasha pertence a sysmgrs (secundário)'

assert_ssh "${VM}" 'id harry | grep -q sysmgrs' 'harry pertence a sysmgrs (secundário)'

assert_ssh "${VM}" 'getent passwd sarah | grep -q nologin' 'sarah tem shell nologin'

assert_ssh "${VM}" 'id sarah | grep -qv sysmgrs' 'sarah não está em sysmgrs'

finish_validation "${EXERCISE}"
