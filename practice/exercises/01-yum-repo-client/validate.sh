#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/validate-common.sh
source "${SCRIPT_DIR}/../../lib/validate-common.sh"

VM=server1
EXERCISE=01-yum-repo-client

echo "=== Validação: ${EXERCISE} (${VM}) ==="
check_vagrant_vm "${VM}"

assert_ssh "${VM}" 'test -n "$(ls -A /etc/yum.repos.d/*.repo 2>/dev/null)"' \
  'ficheiros .repo em /etc/yum.repos.d'

assert_ssh "${VM}" 'grep -rE "baseurl=.*repo.*/(BaseOS|AppStream)" /etc/yum.repos.d/ | grep -q BaseOS && grep -rE "baseurl=.*repo.*/(BaseOS|AppStream)" /etc/yum.repos.d/ | grep -q AppStream' \
  'baseurl aponta para http://repo/BaseOS e AppStream'

assert_ssh "${VM}" 'sudo dnf repolist 2>/dev/null | grep -qE "BaseOS|base|AppStream|app"' \
  'dnf repolist lista os repositórios do lab'

assert_ssh "${VM}" 'rpm -q yum-utils dnf-plugins-core 2>/dev/null | grep -q .' \
  'yum-utils ou dnf-plugins-core instalado'

finish_validation "${EXERCISE}"
