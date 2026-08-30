#!/bin/bash
set -ouex pipefail

systemctl enable NetworkManager libvirtd

# Nix
systemctl enable setup-nix

# Brew
systemctl enable brew-setup.service
systemctl enable brew-update.timer
systemctl enable brew-upgrade.timer