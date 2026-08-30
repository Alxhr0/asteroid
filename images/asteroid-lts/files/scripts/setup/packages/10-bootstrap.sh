#!/bin/bash
set -ouex pipefail

apt-get update

# Get useful utilities for the build
DEBIAN_FRONTEND=noninteractive apt-get install -y git build-essential wget curl

# Bootstrap pacstall
printf 'y\n' | bash -c "$(curl -fsSL https://pacstall.dev/q/install)"