#!/bin/bash -x

echo "Installing dependencies for VirtualBox guest additions."
apt-get --assume-yes install dkms bzip2 linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,')

echo "Testing..."
apt-get --assume-yes install --no-install-recommends libdbus-1-3

echo "Installing VirtualBox Guest Additions."
mount -o loop /home/$username/VBoxGuestAdditions.iso /mnt
yes | sh /mnt/VBoxLinuxAdditions.run
umount /mnt

echo "Cleaning VirtualBox."
rm /home/$username/VBoxGuestAdditions.iso
