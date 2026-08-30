#!/bin/bash
set -ouex pipefail

# Ubuntu

dpkg --add-architecture i386
apt-get update

# home_paulmcauley
echo 'deb http://download.opensuse.org/repositories/home:/paulmcauley/xUbuntu_26.04/ /' | tee /etc/apt/sources.list.d/home:paulmcauley.list
curl -fsSL https://download.opensuse.org/repositories/home:paulmcauley/xUbuntu_26.04/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/home_paulmcauley.gpg

# Xanmod
wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org resolute main non-free" | tee /etc/apt/sources.list.d/xanmod-release.list

# Nushell
wget -qO- https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /etc/apt/keyrings/fury-nushell.gpg
echo "deb [signed-by=/etc/apt/keyrings/fury-nushell.gpg] https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury-nushell.list

# Firefox
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo -e "Types: deb\nURIs: https://packages.microsoft.com/repos/code\nSuites: stable\nComponents: main\nArchitectures: amd64,arm64,armhf\nSigned-By: /usr/share/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/vscode.sources

# Aurora
pacstall -P -A https://github.com/alxhr0/aurora

# NVIDIA
cd /tmp
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2604/x86_64/cuda-keyring_1.1-1_all.deb
DEBIAN_FRONTEND=noninteractive apt-get install -y ./cuda-keyring_1.1-1_all.deb

apt-get update

apt -y modernize-sources

# # Switch to local mirror's
# tee -a /etc/pacman.d/mirrorlist << 'EOF'
# ## Poland
# Server = http://mirror.alldaydev.com/archlinux/$repo/os/$arch
# Server = https://mirror.alldaydev.com/archlinux/$repo/os/$arch
# Server = http://ftp.icm.edu.pl/pub/Linux/dist/archlinux/$repo/os/$arch
# Server = https://ftp.icm.edu.pl/pub/Linux/dist/archlinux/$repo/os/$arch
# Server = http://mirror.juniorjpdj.pl/archlinux/$repo/os/$arch
# Server = https://mirror.juniorjpdj.pl/archlinux/$repo/os/$arch
# Server = http://arch.midov.pl/arch/$repo/os/$arch
# Server = https://arch.midov.pl/arch/$repo/os/$arch
# Server = http://ftp.psnc.pl/linux/archlinux/$repo/os/$arch
# Server = https://ftp.psnc.pl/linux/archlinux/$repo/os/$arch
# Server = http://arch.sakamoto.pl/$repo/os/$arch
# Server = https://arch.sakamoto.pl/$repo/os/$arch
# EOF


# # CachyOS repos - Credits to HuntedRaven7 (taken from blueprint)
# CACHYOS_KEY="F3B607488DB35A47"
# if ! pacman-key -l | grep -q "${CACHYOS_KEY}"; then
#     pacman-key --init
#     pacman-key --recv-key "${CACHYOS_KEY}" --keyserver keyserver.ubuntu.com
#     pacman-key --lsign-key "${CACHYOS_KEY}"
# fi
# if ! grep -q '^\[cachyos\]' /etc/pacman.conf; then
#     pacman -U --noconfirm \
#         'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
#         'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' \
#         'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst'
#     sed -i '/^\[core\]/i [cachyos-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' /etc/pacman.conf

#     sed -i 's/^Architecture = auto/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf
# fi

# if ! grep -q '^DisableSandboxNetwork' /etc/pacman.conf; then
#     sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf
# fi


# # Enable multilib — self-healing, doesn't assume the base image's exact formatting
# if grep -q '^\[multilib\]' /etc/pacman.conf; then
#     echo "multilib already enabled"
# elif grep -q '^#\[multilib\]' /etc/pacman.conf; then
#     sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
# else
#     printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
# fi

# # home_paulmcauley (Klassy)
# # if ! grep -q '^\[home_paulmcauley_Arch\]' /etc/pacman.conf; then
# #     printf '\n[home_paulmcauley_Arch]\nServer = https://download.opensuse.org/repositories/home:/paulmcauley/Arch/x86_64\n' >> /etc/pacman.conf
# # fi

# # key=$(curl -fsSL https://download.opensuse.org/repositories/home:paulmcauley/Arch/$(uname -m)/home_paulmcauley_Arch.key)
# # fingerprint="BB57F2E451C9B8AE8425C0911BC8C8A452A5ED36"

# # pacman-key --init
# # pacman-key --add - <<< "${key}"
# # pacman-key --lsign-key "${fingerprint}"

# # home_Alxhr0 (my own repo)
# if ! grep -q '^\[home_Alxhr0_Arch\]' /etc/pacman.conf; then
#     printf '\n[home_Alxhr0_Arch]\nServer = https://download.opensuse.org/repositories/home:/Alxhr0/Arch/x86_64\n' >> /etc/pacman.conf
# fi
# key=$(curl -fsSL "https://download.opensuse.org/repositories/home:Alxhr0/Arch/$(uname -m)/home_Alxhr0_Arch.key")
# fingerprint="CF092EA23E35D9860BE17D62855052F456F587CF"
# pacman-key --init
# pacman-key --add - <<< "${key}"
# pacman-key --lsign-key "${fingerprint}"

# pacman -Syu --noconfirm
