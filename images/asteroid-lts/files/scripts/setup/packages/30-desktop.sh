#!/bin/bash

set -ouex pipefail


mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png.bak
DEBIAN_FRONTEND=noninteractive apt-get install -y kde-plasma-desktop klassy dolphin kate gwenview okular partitionmanager kcalc kcolorchooser ark merkuro kdepim-addons bluez konsole

DEBIAN_FRONTEND=noninteractive apt-get install -y  mariadb-client mariadb-server
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

PACSTALL_DOWNLOADER=wget pacstall -Ns -P -I kf6-servicemenus-imagetools

mv /usr/share/plymouth/themes/spinner/watermark.png.bak /usr/share/plymouth/themes/spinner/watermark.png
systemctl enable sddm
