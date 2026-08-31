#!/bin/bash

set -ouex pipefail

mkdir -pv /nix
semanage fcontext -a -t usr_t "/nix(/.*)?"
restorecon -R -v /nix

cp -r /asteroid_core/. /

echo "asteroid-lts:latest" > /usr/share/asteroid/image_type