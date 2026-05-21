#!/usr/bin/env bash
# Gera blocos SSH para repo, server1 e server2 (chave Vagrant + IP do exame).
#
# Uso:
#   ./scripts/lab-ssh-config.sh              # imprime em stdout
#   ./scripts/lab-ssh-config.sh --write      # grava em .ssh-config/rhcsa9-lab.conf
#   ./scripts/lab-ssh-config.sh --install    # acrescenta a ~/.ssh/config (marcadores rhcsa9env)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

INSTALL=false
WRITE=false
for arg in "$@"; do
  case "${arg}" in
    --install) INSTALL=true ;;
    --write)   WRITE=true ;;
    -h|--help)
      sed -n '2,7p' "$0" | tail -n +2
      exit 0
      ;;
    *) echo "Opção desconhecida: ${arg}" >&2; exit 2 ;;
  esac
done

lab_cd
lab_require_tools

BEGIN_MARK="# BEGIN rhcsa9env (gerado por scripts/lab-ssh-config.sh)"
END_MARK="# END rhcsa9env"

# IP do exame (eth1) — mesmo com libvirt, SSH costuma funcionar com a chave Vagrant
declare -A LAB_IP=(
  [repo]=192.168.55.149
  [server1]=192.168.55.150
  [server2]=192.168.55.151
)

emit_block() {
  local vm=$1
  local host_alias=$2
  local identity=""
  local mgmt_host=""

  if ! vagrant ssh-config "${vm}" >/dev/null 2>&1; then
    echo "# ${vm}: VM não definida ou sem ssh-config"
    return
  fi

  identity=$(vagrant ssh-config "${vm}" | awk '/IdentityFile / {print $2; exit}')
  mgmt_host=$(vagrant ssh-config "${vm}" | awk '/HostName / {print $2; exit}')

  cat <<EOF
# ${vm} — SSH via rede do exame (IP eth1)
Host ${host_alias}
  HostName ${LAB_IP[${vm}]}
  User vagrant
  Port 22
  IdentityFile ${identity}
  IdentitiesOnly yes
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no

# ${vm} — SSH via rede de gestão Vagrant/libvirt (alternativa)
Host ${host_alias}-mgmt
  HostName ${mgmt_host}
  User vagrant
  Port 22
  IdentityFile ${identity}
  IdentitiesOnly yes
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no

EOF
}

generate_config() {
  echo "${BEGIN_MARK}"
  echo "# Chave: tipicamente ${HOME}/.vagrant.d/insecure_private_key"
  echo "# Exemplo: ssh rhcsa9-server1   ou   ssh rhcsa9-server1-mgmt"
  echo
  emit_block repo rhcsa9-repo
  emit_block server1 rhcsa9-server1
  emit_block server2 rhcsa9-server2
  echo "${END_MARK}"
}

OUT_DIR="${LAB_DIR}/.ssh-config"
OUT_FILE="${OUT_DIR}/rhcsa9-lab.conf"

if [[ "${INSTALL}" == true ]]; then
  lab_require_tools
  TMP=$(mktemp)
  generate_config >"${TMP}"
  if [[ -f "${HOME}/.ssh/config" ]] && grep -qF "${BEGIN_MARK}" "${HOME}/.ssh/config" 2>/dev/null; then
    awk -v b="${BEGIN_MARK}" -v e="${END_MARK}" '
      $0 == b { skip=1; next }
      $0 == e { skip=0; next }
      !skip { print }
    ' "${HOME}/.ssh/config" >"${HOME}/.ssh/config.tmp"
    mv "${HOME}/.ssh/config.tmp" "${HOME}/.ssh/config"
  fi
  mkdir -p "${HOME}/.ssh"
  touch "${HOME}/.ssh/config"
  chmod 600 "${HOME}/.ssh/config"
  cat "${TMP}" >>"${HOME}/.ssh/config"
  rm -f "${TMP}"
  echo "Instalado em ~/.ssh/config"
  echo "  ssh rhcsa9-repo | rhcsa9-server1 | rhcsa9-server2"
  echo "  ssh rhcsa9-server1-mgmt  (IP de gestão do vagrant ssh-config)"
elif [[ "${WRITE}" == true ]]; then
  mkdir -p "${OUT_DIR}"
  generate_config >"${OUT_FILE}"
  chmod 600 "${OUT_FILE}"
  echo "Escrito: ${OUT_FILE}"
  echo "  Inclua no SSH:  Include $(realpath "${OUT_FILE}")"
else
  generate_config
fi
