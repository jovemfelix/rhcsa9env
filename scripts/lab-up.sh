#!/usr/bin/env bash
# Sobe o lab na ordem correta (repo → server2 → server1)
set -euo pipefail
cd "$(dirname "$0")/.."

vagrant up repo
vagrant up server2
vagrant up server1

echo "Lab disponível."
echo "  Saúde:  ./scripts/lab-health.sh"
echo "  SSH:    ./scripts/lab-ssh-config.sh --install"
echo "  Reset:  ./scripts/lab-reset.sh"
