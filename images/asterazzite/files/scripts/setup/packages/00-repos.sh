#!/bin/bash
set -ouex pipefail

dnf -y config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:paulmcauley/Fedora_$(rpm -E %fedora)/home:paulmcauley.repo

dnf -y config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:Alxhr0/Fedora_$(rpm -E %fedora)/home:Alxhr0.repo

echo "[gemfury-nushell]
name=Gemfury Nushell Repo
baseurl=https://yum.fury.io/nushell/
enabled=1
gpgcheck=0
gpgkey=https://yum.fury.io/nushell/gpg.key" | tee /etc/yum.repos.d/fury-nushell.repo

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null
