#!/bin/bash
set -ouex pipefail

systemctl enable libvirtd

# Kmscon
systemctl disable getty@.service
systemctl enable kmsconvt@.service

# Nix
systemctl enable setup-nix
