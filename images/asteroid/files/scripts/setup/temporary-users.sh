#!/bin/bash

set -ouex pipefail

# Setup builder user for AUR packages
useradd -m -s /bin/bash builder
echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder

mkdir -p /build
chown -R builder:builder /build
