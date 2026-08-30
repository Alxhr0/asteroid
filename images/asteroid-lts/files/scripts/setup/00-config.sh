#!/bin/bash

set -ouex pipefail

# Enable -march=raptorlake and -mtune=raptorlake for makepkg.conf
# sed -z -i \
#   -e 's/CFLAGS="[^"]*"/CFLAGS="-march=raptorlake -mtune=raptorlake -O3 -pipe -fno-plt"/' \
#   -e 's/CXXFLAGS="[^"]*"/CXXFLAGS="$CFLAGS"/' \
#   /etc/makepkg.conf