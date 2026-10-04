#!/bin/bash

set -ouex pipefail

dnf -y in klassy merkuro kdepim-addons kdepimlibs kdepim-runtime kf6-servicemenus-imagetools

dnf -y remove filelight krfb kcharselect kfind krdc


dnf -y install mariadb
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
