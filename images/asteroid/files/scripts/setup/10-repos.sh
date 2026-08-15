#!/bin/bash

set -ouex pipefail

pacman --noconfirm -S curl

# CachyOS repos

CACHYOS_KEY="F3B607488DB35A47"

if ! pacman-key -l | grep -q "${CACHYOS_KEY}"; then
    pacman-key --init
    pacman-key --recv-key "${CACHYOS_KEY}" --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key "${CACHYOS_KEY}"
fi

if ! grep -q '^\[cachyos\]' /etc/pacman.conf; then
    pacman -U --noconfirm \
        'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
        'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' \
        'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst' \

    sed -i '/^\[core\]/i \
[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' /etc/pacman.conf
fi

pacman -Syu --noconfirm

# Enable multilib
sed -i '/^#\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf

# home_Alxhr0 (my own repo)
mkdir -pv /root/.gnupg
echo -e "[home_Alxhr0_Arch]\nServer = https://download.opensuse.org/repositories/home:/Alxhr0/Arch/x86_64" >> /etc/pacman.conf
key=$(curl -fsSL https://download.opensuse.org/repositories/home:Alxhr0/Arch/$(uname -m)/home_Alxhr0_Arch.key)
fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"
