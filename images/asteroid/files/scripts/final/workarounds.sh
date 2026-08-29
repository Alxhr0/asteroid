#!/usr/bin/bash

set -eoux pipefail

## Fix Youtube Music
#sed -i 's|/opt/YouTube\\ Music/youtube-music|/usr/share/factory/opt/YouTube\\ Music/youtube-music|' /usr/bin/youtube-music

# Fix Megasync
mv /usr/bin/megasync /opt/megasync/megasync
mv /usr/bin/megasync-bak /usr/bin/megasync

cp -r /usr/share/megasync/resources/* /opt/megasync

# Fix /opt
if [ -d /opt ] && [ ! -L /opt ]; then
    mv /opt /usr/share/factory
fi
ln -sfn /var/opt /opt


