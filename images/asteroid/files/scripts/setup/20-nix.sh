#!/bin/bash

# Credits to HuntedRaven7 (taken from blueprint)

set -ouex pipefail

# Detect SELinux and choose the right context for the Nix store
SELINUX_ENABLED=0
SELINUX_CONTEXT="system_u:object_r:usr_t:s0"
if command -v getenforce &>/dev/null && getenforce 2>/dev/null | grep -qi enforcing; then
    SELINUX_ENABLED=1
fi

# Create systemd mount unit for /nix → /var/nix bind mount
mkdir -p /usr/lib/systemd/system
cat <<EOF > /usr/lib/systemd/system/nix.mount
[Unit]
Description=Bind mount /var/nix to /nix
After=var.mount
Requires=var.mount

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind${SELINUX_ENABLED:+,context=${SELINUX_CONTEXT#*:}}
EOF

if [ "$SELINUX_ENABLED" -eq 1 ]; then
    printf 'SELinuxContext=%s\n' "$SELINUX_CONTEXT" >> /usr/lib/systemd/system/nix.mount
fi

cat <<'EOF' >> /usr/lib/systemd/system/nix.mount

[Install]
WantedBy=local-fs.target
EOF

systemctl enable nix.mount

# Prepare the backing store
mkdir -p /var/nix

# Label the backing store for SELinux if tools are available
if command -v semanage &>/dev/null; then
    semanage fcontext -a -t usr_t "/var/nix(/.*)?" || true
    restorecon -R /var/nix || true
fi

# Run Nix installer - it writes to /nix during the image build
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux \
    --init none \
    --no-confirm \
    --no-modify-profile \
    --prefer-upstream-nix

# Relocate Nix data from /nix to /var/nix so the runtime bind mount exposes it at /nix
if [ -d /nix ] && [ -n "$(find /nix -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
    for item in /nix/*; do
        [ -e "$item" ] || continue
        dest="/var/nix/$(basename "$item")"
        if [ -e "$dest" ]; then
            rm -rf "$dest"
        fi
        mv "$item" "$dest"
    done
fi

# Ensure db permissions on the relocated path
if [ -d /var/nix/var/nix/db ]; then
    chmod 1777 /var/nix/var/nix/db
fi

# Restore SELinux labels on relocated content if tools are available
if command -v restorecon &>/dev/null; then
    restorecon -R /var/nix || true
fi

cat <<'EOF' > /etc/profile.d/nix.sh
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
EOF
