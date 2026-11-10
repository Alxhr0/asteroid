#!/bin/bash

set -ouex pipefail

# Kernel and NVIDIA
pacman --noconfirm -S linux-headers

mkdir -pv /var/tmp
pacman --noconfirm -S nvidia-open-dkms lib32-nvidia-utils vulkan-intel lib32-vulkan-intel