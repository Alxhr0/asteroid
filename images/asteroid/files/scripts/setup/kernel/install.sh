#!/bin/bash

set -ouex pipefail

# Kernel and NVIDIA
pacman --noconfirm -R linux

mkdir -pv /var/tmp
pacman --noconfirm -S linux-cachyos linux-cachyos-headers
pacman --noconfirm -S nvidia-open-dkms lib32-nvidia-utils vulkan-intel lib32-vulkan-intel