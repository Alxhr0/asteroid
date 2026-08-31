#!/bin/bash

set -ouex pipefail

mkdir -pv /nix

cp -r /asteroid_core/. /

echo "asteroid:latest" > /usr/share/asteroid/image_type