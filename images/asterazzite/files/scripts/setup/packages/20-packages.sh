#!/bin/bash

set -ouex pipefail

# CLI tools
rm -r /root
dnf -y in nushell eza bat zoxide htop dnsmasq hourglass neovim man-db
rm -r /root
ln -sT /var/roothome /root

# Fonts
dnf -y install "google-noto-*" jetbrains-mono-fonts-all

dnf -y in --repo='terra' iosevkaterm-nerd-fonts iosevka-nerd-fonts

rm -rf /opt

# Apps
dnf -y in virt-manager qemu libvirt flatpak partitionmanager solaar code

dnf -y in --repo='terra' vesktop

mkdir /opt

cd /tmp
mv /usr/bin/megasync /usr/bin/megasync-bak
wget https://mega.nz/linux/repo/Fedora_44/x86_64/megasync-Fedora_44.x86_64.rpm && dnf -y --setopt=tsflags=noscripts install "$PWD/megasync-Fedora_44.x86_64.rpm"
wget https://mega.nz/linux/repo/Fedora_44/x86_64/dolphin-megasync-Fedora_44.x86_64.rpm && dnf -y --setopt=tsflags=noscripts install "$PWD/dolphin-megasync-Fedora_44.x86_64.rpm"

# Misc
dnf -y install papirus-icon-theme man-pages deepinv20-white-cursors
