#!/bin/bash

set -ouex pipefail

# Bootstrap paru
pacman --noconfirm -S git base-devel
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg --noconfirm -si
rm -rf /tmp/paru

# Kernel and NVIDIA
pacman --noconfirm -R linux

pacman --noconfirm -S linux-cachyos linux-cachyos-headers
pacman --noconfim -S nvidia-open-dkms lib32-nvidia-utils

# CLI tools
pacman --noconfirm -S nushell eza bat zoxide btop htop uutils-coreutils distrobox podman

# Fonts
pacman --noconfirm -S noto-fonts noto-fonts-cjk noto-fonts-emoji

# Apps
pacman --noconfirm -S merkuro virt-manager qemu-desktop flatpak steam partitionmanager

## Megasync
pacman --noconfirm -S wget

cd /tmp
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst && pacman -U "$PWD/megasync-x86_64.pkg.tar.zst"
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/dolphin-megasync-x86_64.pkg.tar.zst && pacman -U "$PWD/dolphin-megasync-x86_64.pkg.tar.zst"

# Misc
pacman --noconfirm -S deepinv20-white-cursors papirus-icon-theme man-pages networkmanager btrfs-progs


systemctl enable NetworkManager libvirtd
