#!/bin/bash
set -ouex pipefail

# CachyOS repos - Credits to HuntedRaven7 (taken from blueprint)
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
        'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst'
    sed -i '/^\[core\]/i [cachyos-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' /etc/pacman.conf

    sed -i 's/^Architecture = auto/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf
fi

if ! grep -q '^DisableSandboxNetwork' /etc/pacman.conf; then
    sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf
fi


# Enable multilib — self-healing, doesn't assume the base image's exact formatting
if grep -q '^\[multilib\]' /etc/pacman.conf; then
    echo "multilib already enabled"
elif grep -q '^#\[multilib\]' /etc/pacman.conf; then
    sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
else
    printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
fi

# home_paulmcauley (Klassy)
if ! grep -q '^\[home_paulmcauley_Arch\]' /etc/pacman.conf; then
    printf '\n[home_paulmcauley_Arch]\nServer = https://download.opensuse.org/repositories/home:/paulmcauley/Arch/x86_64\n' >> /etc/pacman.conf
fi

key=$(curl -fsSL https://download.opensuse.org/repositories/home:paulmcauley/Arch/$(uname -m)/home_paulmcauley_Arch.key)
fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"

# home_Alxhr0 (my own repo)
if ! grep -q '^\[home_Alxhr0_Arch\]' /etc/pacman.conf; then
    printf '\n[home_Alxhr0_Arch]\nServer = https://download.opensuse.org/repositories/home:/Alxhr0/Arch/x86_64\n' >> /etc/pacman.conf
fi
key=$(curl -fsSL "https://download.opensuse.org/repositories/home:Alxhr0/Arch/$(uname -m)/home_Alxhr0_Arch.key")
fingerprint="CF092EA23E35D9860BE17D62855052F456F587CF"
pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"

pacman -Syu --noconfirm
