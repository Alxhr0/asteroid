#!/bin/bash

set -ouex pipefail
# Bootstrap paru
sed -i \
  -e 's/^CFLAGS="[^"]*"/CFLAGS="-march=raptorlake -mtune=raptorlake -O3 -pipe -fno-plt"/' \
  -e 's/^CXXFLAGS="[^"]*"/CXXFLAGS="\$CFLAGS"/' \
  /etc/makepkg.conf

pacman --noconfirm -S git base-devel
su builder -c "cd /build && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm"
rm -rf /build/paru-bin

# Kernel and NVIDIA
pacman --noconfirm -R linux

pacman --noconfirm -S linux-cachyos linux-cachyos-headers
pacman --noconfirm -S nvidia-open-dkms lib32-nvidia-utils

# CLI tools
pacman --noconfirm -S nushell eza bat zoxide btop htop uutils-coreutils distrobox podman

# Fonts
pacman --noconfirm -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono ttf-jetbrains-mono-nerd

# Apps
pacman --noconfirm -S merkuro virt-manager qemu-desktop flatpak steam partitionmanager firefox bazaar

## Megasync
pacman --noconfirm -S wget

cd /tmp
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst && pacman -U "$PWD/megasync-x86_64.pkg.tar.zst"
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/dolphin-megasync-x86_64.pkg.tar.zst && pacman -U "$PWD/dolphin-megasync-x86_64.pkg.tar.zst"

# Misc
pacman --noconfirm -S deepinv20-white-cursors papirus-icon-theme man-pages networkmanager btrfs-progs


systemctl enable NetworkManager libvirtd
