#!/bin/bash

set -ouex pipefail

# Kernel
dnf -y remove "kernel*"
dnf -y install --setopt=tsflags=noscripts kernel-cachyos-lto kernel-cachyos-lto-devel-matched
KVER=$(rpm -q kernel-cachyos-lto-core --qf '%{version}-%{release}.%{arch}\n')
depmod -a "$KVER" && \
kernel-install add "$KVER" /usr/lib/modules/"$KVER"/vmlinuz

# NVIDIA
dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda
akmods --force --kernels "$KVER"
depmod -a "$KVER"