#!/bin/bash

synchronize_media () {
  ## Synchonize media library to smart proxies
  hammer --no-headers proxy list --fields name | while read line
  do
    smartproxy=$line
    ## Synchronize smart proxy
    echo "Synchronizing media content on $smartproxy"
    rsync -Wavq --delete-after /opt/media-library/ root@$smartproxy:/var/www/lighttpd/media
  done
  echo "Sync complete."
}

if [ -f "/opt/scripts/sync_media.lock" ]; then
  echo "Lockfile exists. Cannot continue."
  exit 0
fi

if [ -z "$(ls -A /opt/iso/)" ]; then
  echo "No new isos found. Synchronizing media to smart proxies."
  touch /opt/scripts/sync_media.lock
  synchronize_media
  rm -rf /opt/scripts/sync_media.lock
  exit 0
fi

## Create lock file
touch /opt/scripts/sync_media.lock
cd /opt/iso
for i in *.iso
do
  dname=$(basename "$i" .iso)
  mkdir -p /opt/iso/tmp
  ## Create temp directory to store iso contents
  fchange=$(($(($(date +%s) - $(stat /opt/iso/$i -c %Y)))))
  if [ $fchange -lt "10" ]; then
    echo "file is still copying. Exiting."
    exit 0
  fi
  echo "[iso: $dname]"
  echo " Mounting $i to /opt/iso/tmp"
  mount -t iso9660 -o loop,ro /opt/iso/$i /opt/iso/tmp
  echo "  Extracting ISO contents to media library"
  rsync -Wavq /opt/iso/tmp /opt/media-library
  echo "  Finalizing iso image $dname"
  mv /opt/media-library/tmp /opt/media-library/$dname
  umount /opt/iso/tmp
  rm -rf /opt/iso/$i
done
synchronize_media

## cleanup
rm -rf /opt/iso/tmp
rm -rf /opt/scripts/sync_media.lock
