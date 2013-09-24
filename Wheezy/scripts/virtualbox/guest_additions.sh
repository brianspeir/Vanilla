#!/bin/bash -x


echo "Installing dependencies for VirtualBox guest additions."
apt-get --assume-yes install dkms bzip2 linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,')

echo "Testing..."
apt-get --assume-yes install --no-install-recommends libdbus-1-3

#
echo "Installing VirtualBox Guest Additions."
mount /media/cdrom1
yes | sh /media/cdrom1/VBoxLinuxAdditions.run
umount /media/cdrom1
