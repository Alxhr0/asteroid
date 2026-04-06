#!/bin/bash

set -ouex pipefail

dnf5 install -y wget dnf5-plugins

# Enable RPMFusion
#dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo

# Starship
dnf copr -y enable atim/starship 

# Enable home_Alxhr0
dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:Alxhr0/Fedora_$(rpm -E %fedora)/home:Alxhr0.repo

dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:paul4us/Fedora_$(rpm -E %fedora)/home:paul4us.repo

# Eza
dnf copr -y enable alternateved/eza 

# Nushell
echo "[gemfury-nushell]
name=Gemfury Nushell Repo
baseurl=https://yum.fury.io/nushell/
enabled=1
gpgcheck=0
gpgkey=https://yum.fury.io/nushell/gpg.key" | tee /etc/yum.repos.d/fury-nushell.repo

# Enable the BLU kernel
#dnf5 -y copr enable sentry/kernel-blu

# Enable Steam repo
#dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo
