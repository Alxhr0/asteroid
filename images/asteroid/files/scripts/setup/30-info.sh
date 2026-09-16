#!/bin/bash
set -ouex pipefail

OS_REL="${1:-/asteroid_core/images/asteroid/files/system_files/etc/os-release}"

if [ -f "$OS_REL" ]; then
	rm /etc/os-release
	cp -f "$OS_REL" /usr/lib/os-release
	ln -sf ../usr/lib/os-release /etc/os-release

	if [ -f /etc/default/grub ]; then
		if grep -q "^GRUB_DISTRIBUTOR=" /etc/default/grub; then
			sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="Asteroid"/' /etc/default/grub
		else
			echo 'GRUB_DISTRIBUTOR="Asteroid"' >> /etc/default/grub
		fi
	fi
fi
