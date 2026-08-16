#!/bin/bash
set -ouex pipefail

systemctl enable NetworkManager libvirtd

# Brew
systemctl enable brew-setup.service
systemctl enable brew-update.timer
systemctl enable brew-upgrade.timer