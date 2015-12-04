#!/bin/sh

echo "run post_build.sh"
TARGETDIR=$1
BOARDDIR=$BR2_EXTERNAL/board/virt2real/v1

# Set root password to 'root'. Password generated with
# mkpasswd, from the 'whois' package in Debian/Ubuntu.
sed -i 's%root::%root:8kfIfYHmcyQEE:%' $TARGETDIR/etc/shadow

# Remove bad files
rm $TARGETDIR/etc/resolv.conf

locales=`ls --ignore="ru" --ignore="en*" $TARGETDIR/usr/share/locale`
for i in $locales ; do
    rm -R $TARGETDIR/usr/share/locale/$i
done

# Copy the rootfs additions
# cp -r $BOARDDIR/rootfs-additions/* $TARGETDIR.swp
