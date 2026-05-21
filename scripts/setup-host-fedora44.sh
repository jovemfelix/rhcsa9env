#!/usr/bin/env bash
# Host setup for Fedora 44 — Vagrant + libvirt (KVM) + Ansible
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root: sudo $0"
  exit 1
fi

TARGET_USER="${SUDO_USER:-${USER}}"
TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"

echo "==> Instalando pacotes do host (libvirt/KVM)"
dnf install -y \
  @virtualization \
  vagrant \
  ansible \
  git \
  gcc \
  make \
  patch \
  libvirt \
  libvirt-devel \
  qemu-kvm \
  ruby-devel \
  libxslt-devel \
  libxml2-devel \
  sshpass

echo "==> Habilitando libvirtd"
systemctl enable --now libvirtd

if ! id -nG "${TARGET_USER}" | grep -qw libvirt; then
  usermod -aG libvirt "${TARGET_USER}"
  echo "Usuário ${TARGET_USER} adicionado ao grupo libvirt — faça logout/login."
fi

echo "==> Instalando plugin vagrant-libvirt"
if ! sudo -u "${TARGET_USER}" vagrant plugin list 2>/dev/null | grep -q vagrant-libvirt; then
  sudo -u "${TARGET_USER}" vagrant plugin install vagrant-libvirt
fi

echo "==> (Opcional) VirtualBox via RPM Fusion"
if dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null; then
  dnf install -y akmod-VirtualBox VirtualBox kernel-devel || true
  KVER="$(uname -r)"
  akmods --kernels "${KVER}" 2>/dev/null || true
  systemctl restart vboxdrv.service 2>/dev/null || true
  id -nG "${TARGET_USER}" | grep -qw vboxusers || usermod -aG vboxusers "${TARGET_USER}"
fi

echo "==> Verificando instalação"
vagrant --version
ansible --version | head -1
virsh -c qemu:///system list --all 2>/dev/null | head -5 || true
sudo -u "${TARGET_USER}" vagrant plugin list 2>/dev/null || true

echo "Pronto. No diretório do projeto: ./scripts/lab-up.sh"
