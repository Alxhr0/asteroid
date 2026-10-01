#!/usr/bin/bash

set -eoux pipefail

echo "::group::Executing build-initramfs"
trap 'echo "::endgroup::"' EXIT

KVER=$(basename "$(find /usr/lib/modules -maxdepth 1 -mindepth 1 -type d | tail -n 1)")
dracut --force --no-hostonly --reproducible --zstd --verbose --add ostree --kver "${KVER}" "/usr/lib/modules/${KVER}/initramfs.img"

chmod 0600 /usr/lib/modules/"$KVER"/initramfs.img
