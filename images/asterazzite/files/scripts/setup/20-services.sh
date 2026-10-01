#!/bin/bash
set -ouex pipefail

systemctl enable libvirtd

# Nix
systemctl enable setup-nix
