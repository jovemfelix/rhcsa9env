#!/usr/bin/env bash
# Gestão de exercícios RHCSA em practice/exercises/
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXERCISES="${ROOT}/practice/exercises"

usage() {
  cat <<'EOF'
Uso:
  ./scripts/lab-practice.sh list
  ./scripts/lab-practice.sh validate <id|pasta>   # ex: 01 ou 01-yum-repo-client
  ./scripts/lab-practice.sh question <id|pasta>   # mostra QUESTION.md (enunciado)
  ./scripts/lab-practice.sh reset <id|pasta>      # remove artefactos do exercício

Enunciado em inglês (QUESTION.md); validação em português (validate.sh + VALIDATION.md).
EOF
}

resolve_exercise_dir() {
  local arg=$1
  if [[ -d "${EXERCISES}/${arg}" ]]; then
    echo "${EXERCISES}/${arg}"
    return
  fi
  local match
  match=$(find "${EXERCISES}" -maxdepth 1 -type d -name "${arg}-*" 2>/dev/null | head -1)
  if [[ -n "${match}" ]]; then
    echo "${match}"
    return
  fi
  echo "ERROR: exercício não encontrado: ${arg}" >&2
  exit 1
}

cmd_list() {
  echo "Exercícios em ${EXERCISES}:"
  for d in "${EXERCISES}"/*/; do
    [[ -f "${d}/QUESTION.md" ]] || continue
    basename "${d}"
  done | sort
}

cmd_validate() {
  local dir
  dir=$(resolve_exercise_dir "$1")
  bash "${dir}/validate.sh"
}

cmd_question() {
  local dir
  dir=$(resolve_exercise_dir "$1")
  less "${dir}/QUESTION.md" 2>/dev/null || cat "${dir}/QUESTION.md"
}

cmd_reset() {
  local dir
  dir=$(resolve_exercise_dir "$1")
  local name
  name=$(basename "${dir}")
  echo "==> Reset parcial: ${name}"

  case "${name}" in
    02-users-groups)
      vagrant ssh server1 -c 'sudo userdel -rf natasha harry sarah 2>/dev/null; sudo groupdel sysmgrs 2>/dev/null; true'
      ;;
    03-collaboration-directory)
      vagrant ssh server1 -c 'sudo rm -rf /home/managers'
      ;;
    04-cron-natasha)
      vagrant ssh server1 -c 'sudo crontab -u natasha -r 2>/dev/null; true'
      ;;
    05-acl-var-tmp-fstab)
      vagrant ssh server1 -c 'sudo rm -f /var/tmp/fstab; sudo setfacl -b /var/tmp/fstab 2>/dev/null; true'
      ;;
    06-selinux-httpd-port82)
      vagrant ssh server1 -c 'sudo rm -f /var/www/html/file1 /var/www/html/file2 /etc/httpd/conf.d/listen82.conf 2>/dev/null; sudo semanage port -d -t http_port_t -p tcp 82 2>/dev/null; true'
      ;;
    07-lvm-database-server2)
      vagrant ssh server2 -c 'sudo umount /mnt/database 2>/dev/null; sudo lvremove -fy datastore/database 2>/dev/null; sudo vgremove -fy datastore 2>/dev/null; sudo pvremove -fy /dev/vdc 2>/dev/null; sudo wipefs -a /dev/vdc 2>/dev/null; true'
      ;;
    01-yum-repo-client)
      vagrant ssh server1 -c 'sudo rm -rf /etc/yum.repos.d/*'
      ;;
    *)
      echo "Sem reset automático para ${name}. Usa ./scripts/lab-reset.sh para reset completo."
      exit 1
      ;;
  esac
  echo "Feito. Podes repetir o exercício."
}

main() {
  cd "${ROOT}"
  local cmd=${1:-}
  shift || true
  case "${cmd}" in
    list)     cmd_list ;;
    validate) cmd_validate "${1:?id}" ;;
    question) cmd_question "${1:?id}" ;;
    reset)    cmd_reset "${1:?id}" ;;
    -h|--help|"") usage ;;
    *) echo "Comando desconhecido: ${cmd}" >&2; usage; exit 2 ;;
  esac
}

main "$@"
