#!/bin/bash

set -ouex pipefail

mkdir -pv /nix

echo "asteroid:latest" > /usr/share/asteroid/image_type