#!/bin/sh

echo "run post_build.sh"
TARGETDIR=$1
BOARDDIR=$BR2_EXTERNAL/board/virt2real/v1

# Set root password to 'root'. Password generated with
# mkpasswd, from the 'whois' package in Debian/Ubuntu.
# sed -i 's%root::%root:8kfIfYHmcyQEE:%' $TARGETDIR/etc/shadow

# Remove bad files
rm $TARGETDIR/etc/resolv.conf

locales=`ls --ignore="ru" --ignore="en*" $TARGETDIR/usr/share/locale`
for i in $locales ; do
    rm -R $TARGETDIR/usr/share/locale/$i
done

# remove dhcpd from startup
if [ -f ${TARGETDIR}/etc/init.d/S80dhcp-server ];
then
    mv ${TARGETDIR}/etc/init.d/S80dhcp-server ${TARGETDIR}/etc/init.d.sample/
fi

# Copy the rootfs additions
# cp -r $BOARDDIR/rootfs-additions/* $TARGETDIR.swp

# make dir /boot
if [ ! -d "${TARGETDIR}/boot" ]
then 
    mkdir "${TARGETDIR}/boot"
fi

# mount boot record in the /etc/fstab
if grep "mmcblk0p1" "${TARGETDIR}/etc/fstab" > /dev/null
then
echo "/dev/mmcblk0p1 exists in the /etc/fstab"
else
cat << 'EOF' >> "${TARGETDIR}/etc/fstab"
/dev/mmcblk0p1	/boot		vfat	defaults	0	2
EOF
fi