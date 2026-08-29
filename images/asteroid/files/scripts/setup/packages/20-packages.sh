#!/bin/bash

set -ouex pipefail

# CLI tools
pacman --noconfirm -S nushell eza bat zoxide btop htop distrobox podman fastfetch inetutils dnsmasq hourglass neovim man-db

# Fonts
pacman --noconfirm -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono ttf-jetbrains-mono-nerd

# Apps
pacman --noconfirm -S virt-manager qemu-desktop flatpak steam partitionmanager firefox vesktop solaar

rm /opt
mkdir /opt

# AUR packages
su builder -c "yay --noconfirm -S visual-studio-code-bin vmware-workstation"

# su builder -c "cd /build && git clone https://aur.archlinux.org/vmware-workstation.git && cd vmware-workstation && makepkg --noconfirm -si"
# rm -r /build/vmware-workstation

## Megasync
cd /tmp
mv /usr/bin/megasync /usr/bin/megasync-bak
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst && pacman --noconfirm -U "$PWD/megasync-x86_64.pkg.tar.zst"
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/dolphin-megasync-x86_64.pkg.tar.zst && pacman --noconfirm -U "$PWD/dolphin-megasync-x86_64.pkg.tar.zst"
pacman -Sy

# Misc
pacman --noconfirm -S deepinv20-white-cursors papirus-icon-theme man-pages networkmanager 



