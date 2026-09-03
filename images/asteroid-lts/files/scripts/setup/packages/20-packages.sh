#!/bin/bash

set -ouex pipefail

# CLI tools
rm -r /root
dnf -y install nushell eza bat zoxide just btop htop distrobox podman fastfetch dnsmasq man-db hourglass
rm -r /root
ln -sT /var/roothome /root

# Fonts
dnf -y install "google-noto-*" iosevkaterm-nerd-fonts iosevka-nerd-fonts jetbrains-mono-fonts-all

# Apps
dnf -y install virt-manager qemu flatpak steam solaar code firefox code vesktop

rm /opt
mkdir /opt

## Megasync
cd /tmp
mv /usr/bin/megasync /usr/bin/megasync-bak
wget https://mega.nz/linux/repo/Fedora_44/x86_64/megasync-Fedora_44.x86_64.rpm && dnf -y --setopt=tsflags=noscripts install "$PWD/megasync-Fedora_44.x86_64.rpm"
wget https://mega.nz/linux/repo/Fedora_44/x86_64/dolphin-megasync-Fedora_44.x86_64.rpm && dnf -y --setopt=tsflags=noscripts install "$PWD/dolphin-megasync-Fedora_44.x86_64.rpm"

# Misc
dnf -y install papirus-icon-theme man-pages deepinv20-white-cursors


