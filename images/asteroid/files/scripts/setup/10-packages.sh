#!/bin/bash

set -ouex pipefail

# CLI tools
dnf5 install -y hourglass fastfetch nushell tmate htop btop aria2 eza bat zoxide starship kf6-servicemenus-imagetools fd-find

# Apps
dnf5 install -y virt-install libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer libguestfs-tools python3-libguestfs virt-top edk2-ovmf swtpm partitionmanager code merkuro deepinv20-white-cursors

# Gaming!
dnf5 in -y --setopt=install_weak_deps=False gamemode

# Fonts
dnf5 install -y google-noto-fonts-all jetbrains-mono-fonts-all

dnf5 install -y klassy

dnf5 in -y papirus-icon-theme

# Remove unused packages
dnf5 rm -y krfb krfb-libs kfind filelight sunshine
