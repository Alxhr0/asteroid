#!/bin/bash

set -ouex pipefail


mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png.bak
pacman --noconfirm -S plasma plasma-login-manager dolphin kate gwenview okular partitionmanager kcalc kcolorchooser ark merkuro kdepim-addons bluez konsole klassy

pacman --noconfirm -S mariadb
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

su builder -c "yay --noconfirm -S kf6-servicemenus-imagetools"


mv /usr/share/plymouth/themes/spinner/watermark.png.bak /usr/share/plymouth/themes/spinner/watermark.png
systemctl enable plasmalogin
