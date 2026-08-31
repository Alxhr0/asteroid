#!/usr/bin/env bash

set -ouex pipefail


# Install Nix in daemon mode if not already present
if ! command -v nix > /dev/null 2>&1; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install ostree --no-confirm
fi

# Enable experimental features (idempotent)
mkdir -p /etc/nix
if ! grep -q "^experimental-features = nix-command flakes" /etc/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
fi

# Set proper ownership and permissions on /nix for daemon operation
chown root:nixbld /nix
chmod 0775 /nix

# Ensure the daemon socket parent directory exists with correct ownership
install -d -m 0755 /nix/var/nix
chown root:nixbld /nix/var/nix

# Create per-user Nix profile directories for existing non-root users
while IFS=: read -r username _ uid _ _ _ shell; do
    if [[ "$uid" -ge 1000 ]] && [[ "$shell" != */nologin ]] && [[ "$shell" != */false ]]; then
        mkdir -p "/nix/var/nix/profiles/per-user/${username}"
        chown "${username}:nixbld" "/nix/var/nix/profiles/per-user/${username}"
        chmod 0755 "/nix/var/nix/profiles/per-user/${username}"
    fi
done < /etc/passwd

# Add existing non-root users to the nixbld group so they can communicate with the daemon
while IFS=: read -r username _ uid _ _ _ shell; do
    if [[ "$uid" -ge 1000 ]] && [[ "$shell" != */nologin ]] && [[ "$shell" != */false ]]; then
        usermod -aG nixbld "${username}" || true
    fi
done < /etc/passwd

mkdir -pv /etc/environment.d

# Make Nix available in all contexts (login shells, systemd services, etc.)
echo 'PATH="${PATH}:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin"' > /etc/environment.d/50-nix.conf

# Provide shell integration for login shells
echo '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' > /etc/profile.d/nix.sh

# Enable the nix-daemon service so it starts at boot
systemctl enable nix-daemon.service || true

# Fix SELinux context on Fedora/RHEL-based systems so Nix can manage /nix
if command -v chcon > /dev/null 2>&1; then
    chcon -R -u system_u -r object_r -t unconfined_mgmt_t /nix 2>/dev/null || true
fi