#!/bin/bash

set -ouex pipefail


pacman --noconfirm -S plasma plasma-login-manager dolphin kate gwenview okular partitionmanager kcalc kcolorchooser ark merkuro kdepim-addons bluez konsole

pacman --noconfirm -S mariadb
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

su builder -c "yay --noconfirm -S klassy kf6-servicemenus-imagetools"

systemctl enable plasmalogin
