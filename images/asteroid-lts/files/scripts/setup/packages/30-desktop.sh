#!/bin/bash

set -ouex pipefail


mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png.bak
dnf -y install plasma-desktop plasmalogin kwin_wayland plasma-workspace kf6-servicemenus-imagetools klassy dolphin kate gwenview okular partitionmanager kcalc kcolorchooser ark merkuro kdepim-addons bluez konsole

dnf -y remove filelight krfb kcharselect kfind

dnf -y install mariadb
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

mv /usr/share/plymouth/themes/spinner/watermark.png.bak /usr/share/plymouth/themes/spinner/watermark.png
systemctl enable plasmalogin
