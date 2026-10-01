#!/bin/bash

set -ouex pipefail

mkdir -pv /nix

cp -r /asterazzite_core/. /

# These are build-context scaffolding, not image content
rm -rf /scripts /system_files /unused_files

echo "asterazzite:latest" > /usr/share/asteroid/image_type
