#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

gtk-update-icon-cache

rm -rf /tmp/* || true
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

rm -f /etc/sudoers.d/builder
userdel -r builder

mv /opt /usr/share/factory
rm /opt
ln -s /var/opt /opt

echo "::endgroup::"
