#!/bin/bash

set -ouex pipefail

# Kernel
DEBIAN_FRONTEND=noninteractive apt-get remove -y linux-image-generic
DEBIAN_FRONTEND=noninteractive apt-get install -y linux-xanmod-x64v3

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends dkms libelf-dev clang lld llvm


# NVIDIA
DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-driver-610-open
