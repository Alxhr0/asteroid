#!/bin/bash

set -ouex pipefail

# CLI tools

# Fix for Nushell's broken post-inst script
rm -r /root

dnf5 install -y hourglass fastfetch nushell tmate htop btop aria2 eza bat zoxide kf6-servicemenus-imagetools fd-find


# Apps

# Megasync
rm /opt
mkdir /opt


# Move the script so that it doesn't get overwritten
mv /usr/bin/megasync /usr/bin/megasync-bak

wget https://mega.nz/linux/repo/Fedora_44/x86_64/megasync-Fedora_44.x86_64.rpm && dnf5 install --setopt=tsflags=noscripts -y "$PWD/megasync-Fedora_44.x86_64.rpm"
rm "$PWD/megasync-Fedora_44.x86_64.rpm"

# Replace the binary with a script that set LD_LIBRARY_PATH to make it run. 
mv /usr/bin/megasync /opt/megasync/megasyn
mv /usr/bin/megasync-bak /usr/bin/megasync

# Dolphin support
wget https://mega.nz/linux/repo/Fedora_44/x86_64/dolphin-megasync-Fedora_44.x86_64.rpm
dnf install --setopt=tsflags=noscripts -y ./dolphin-megasync-Fedora_44.x86_64.rpm
rm ./dolphin-megasync-Fedora_44.x86_64.rpm

dnf5 install -y virt-install libvirt-daemon libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer libguestfs-tools python3-libguestfs virt-top edk2-ovmf swtpm partitionmanager code merkuro deepinv20-white-cursors

# Gaming!
dnf5 in -y --setopt=install_weak_deps=False gamemode

# Fonts
dnf5 install -y google-noto-fonts-all jetbrains-mono-fonts-all default-fonts-cjk

dnf5 install -y klassy

dnf5 in -y papirus-icon-theme

# Remove unused packages
dnf5 rm -y krfb krfb-libs kfind filelight sunshine krdc
