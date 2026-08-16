#!/bin/bash
set -ouex pipefail

# Get useful utilities for the build
pacman --noconfirm -S git base-devel wget curl

# Bootstrap yay
su builder -c "cd /build && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"
rm -rf /build/yay