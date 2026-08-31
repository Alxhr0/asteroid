#!/bin/bash
set -ouex pipefail

# home_paulmcauley
dnf -y config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:paulmcauley/Fedora_44/home:paulmcauley.repo

# Terra
dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

# CachyOS kernel
dnf -y copr enable bieszczaders/kernel-cachyos-lto fedora-$(rpm -E %fedora)-$(arch)

# Nushell
echo "[gemfury-nushell]
name=Gemfury Nushell Repo
baseurl=https://yum.fury.io/nushell/
enabled=1
gpgcheck=0
gpgkey=https://yum.fury.io/nushell/gpg.key" | tee /etc/yum.repos.d/fury-nushell.repo

# VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

# home_Alxhr0
dnf -y config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:Alxhr0/Fedora_$(rpm -E %fedora)/home:Alxhr0.repo

# RPMFusion
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf check-update
