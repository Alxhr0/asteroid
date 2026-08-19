#!/bin/bash

set -ouex pipefail

mkdir -pv /nix

rm /usr/local

ln -sT ../var/usrlocal /usr/local

echo "asteroid:latest" > /usr/share/asteroid/image_type