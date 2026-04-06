#!/bin/bash

set -ouex pipefail

# CLI tools
rm -r /root # for Nushell
dnf5 install -y hourglass fastfetch nushell tmate htop btop aria2 eza bat zoxide starship kf6-servicemenus-imagetools fd-find wezterm-git

# echo "Installing Nushell.."
# wget https://github.com/nushell/nushell/releases/download/0.108.0/nu-0.108.0-x86_64-unknown-linux-gnu.tar.gz -P /tmp
#
# tar -xvf /tmp/nu-0.108.0-x86_64-unknown-linux-gnu.tar.gz -C /tmp
#
# cp -v /tmp/nu-0.108.0-x86_64-unknown-linux-gnu/nu /usr/bin/nu
# for nu_plugin in nu_plugin_formats nu_plugin_gstat nu_plugin_inc nu_plugin_polars nu_plugin_query; do cp -v /tmp/nu-0.108.0-x86_64-unknown-linux-gnu/$nu_plugin /usr/libexec/nushell/$nu_plugin; done
#
# systemctl enable nushell-post-inst

# Kernel
#rpm-ostree override replace --experimental --freeze --from repo='copr:copr.fedorainfracloud.org:sentry:kernel-blu' kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra

# Drivers
#dnf5 install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

# Apps
dnf5 install -y virt-install libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer libguestfs-tools python3-libguestfs virt-top edk2-ovmf swtpm gparted code merkuro

# Gaming!
dnf5 in -y --setopt=install_weak_deps=False gamemode

# Fonts
dnf5 install -y google-noto-fonts-all jetbrains-mono-fonts-all

# Misc NOTE: Uncomment after home_paul4us supports F43
dnf5 install -y klassy

dnf5 in -y papirus-icon-theme

# Remove unused packages
dnf5 rm -y krfb krfb-libs kfind filelight sunshine
