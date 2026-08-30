#!/bin/bash

set -ouex pipefail

# CLI tools
rm -r /root
DEBIAN_FRONTEND=noninteractive apt-get install -y nushell eza bat zoxide btop htop distrobox podman fastfetch dnsmasq man-db
ln -s /bin/batcat /bin/bat

# Fonts
DEBIAN_FRONTEND=noninteractive apt-get install -y "fonts-noto-*" fonts-jetbrains-mono

# Apps
DEBIAN_FRONTEND=noninteractive apt-get install -y virt-manager qemu-system flatpak steam solaar code

rm /opt
mkdir /opt

# AUR packages
#su builder -c "yay --noconfirm -S visual-studio-code-bin vmware-workstation"

PACSTALL_DOWNLOADER=wget pacstall -Ns -P -I hourglass

# su builder -c "cd /build && git clone https://aur.archlinux.org/vmware-workstation.git && cd vmware-workstation && makepkg --noconfirm -si"
# rm -r /build/vmware-workstation

## Megasync
cd /tmp
mv /usr/bin/megasync /usr/bin/megasync-bak
wget https://mega.nz/linux/repo/xUbuntu_26.04/amd64/megasync-xUbuntu_26.04_amd64.deb && DEBIAN_FRONTEND=noninteractive apt-get install -y "$PWD/megasync-xUbuntu_26.04_amd64.deb"
wget https://mega.nz/linux/repo/xUbuntu_26.04/amd64/dolphin-megasync-xUbuntu_26.04_amd64.deb && DEBIAN_FRONTEND=noninteractive apt-get install -y "$PWD/dolphin-megasync-xUbuntu_26.04_amd64.deb"
apt-get update

# Misc
DEBIAN_FRONTEND=noninteractive apt-get install -y papirus-icon-theme manpages network-manager ubuntu-restricted-extras
PACSTALL_DOWNLOADER=wget pacstall -Ns -P -I deepinv20-white-cursors-git



