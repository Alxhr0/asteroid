#!/bin/bash

set -ouex pipefail

mkdir -pv /nix

# Remove certain Bazzite files that are not needed in the image
rm -rf /usr/share/templates/*.desktop

cp -r /asterazzite_core/. /

# Not needed in the actual image
rm -rf /scripts /system_files /unused_files

echo "asterazzite:latest" > /usr/share/asteroid/image_type
