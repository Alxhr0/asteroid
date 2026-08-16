#!/bin/bash

set -ouex pipefail
# Bootstrap paru
sed -z -i \
  -e 's/CFLAGS="[^"]*"/CFLAGS="-march=raptorlake -mtune=raptorlake -O3 -pipe -fno-plt"/' \
  -e 's/CXXFLAGS="[^"]*"/CXXFLAGS="$CFLAGS"/' \
  /etc/makepkg.conf

pacman --noconfirm -S git base-devel
su builder -c "cd /build && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"
rm -rf /build/yay

# Kernel and NVIDIA
pacman --noconfirm -R linux

mkdir -pv /var/tmp
pacman --noconfirm -S linux-cachyos linux-cachyos-headers
pacman --noconfirm -S nvidia-open-dkms lib32-nvidia-utils vulkan-intel lib32-vulkan-intel

# CLI tools
pacman --noconfirm -S nushell eza bat zoxide btop htop distrobox podman fastfetch inetutils dnsmasq hourglass neovim man-db

# Fonts
pacman --noconfirm -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono ttf-jetbrains-mono-nerd

# Apps
pacman --noconfirm -S merkuro virt-manager qemu-desktop flatpak steam partitionmanager firefox vesktop solaar

rm /opt
mkdir /opt


su builder -c "yay --noconfirm -S visual-studio-code-bin vmware-workstation pear-desktop-bin"

## Fix Youtube Music
sed -i 's|/opt/YouTube\\ Music/youtube-music|/usr/share/factory/opt/YouTube\\ Music/youtube-music|' /usr/bin/youtube-music

## Megasync
pacman --noconfirm -S wget

cd /tmp
mv /usr/bin/megasync /usr/bin/megasync-bak
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst && pacman --noconfirm -U "$PWD/megasync-x86_64.pkg.tar.zst"
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/dolphin-megasync-x86_64.pkg.tar.zst && pacman --noconfirm -U "$PWD/dolphin-megasync-x86_64.pkg.tar.zst"

mv /usr/bin/megasync /opt/megasync/megasync
mv /usr/bin/megasync-bak /usr/bin/megasync

pacman -Sy

# Misc
pacman --noconfirm -S deepinv20-white-cursors papirus-icon-theme man-pages networkmanager 


systemctl enable NetworkManager libvirtd bluetooth

# Brew

systemctl enable brew-setup.service
systemctl enable brew-update.timer
systemctl enable brew-upgrade.timer
