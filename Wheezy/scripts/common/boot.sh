#!/bin/bash -x


# Boot --------------------------------------------------------------------- #

#
echo "Preventing PC speaker from loading because we don't need it."
cat >> /etc/modprobe.d/blacklist.conf <<EOF
# disable pc speaker
blacklist pcspkr
EOF

#
echo "Disabling getty processes."
inittab_path="/etc/inittab"
tty1='1:2345:respawn:/sbin/getty 38400 tty1'
ttyx=':23:respawn:/sbin/getty 38400 tty'
sed -i "s_^${tty1}_#${tty1}_" $inittab_path
sed -i "s_^2${ttyx}2_#2${ttyx}2_" $inittab_path
sed -i "s_^3${ttyx}3_#3${ttyx}3_" $inittab_path
sed -i "s_^4${ttyx}4_#4${ttyx}4_" $inittab_path
sed -i "s_^5${ttyx}5_#5${ttyx}5_" $inittab_path
sed -i "s_^6${ttyx}6_#6${ttyx}6_" $inittab_path

sed -i 's_^2:23:respawn:/sbin/getty 38400 tty2_#2:23:respawn:/sbin/getty 38400 tty2' /etc/

#
echo "Configuring grub."
sed -i 's/^GRUB_TIMEOUT=[0-9]/GRUB_TIMEOUT=0\nGRUB_HIDDEN_TIMEOUT=true/' /etc/default/grub
sed -i 's/^GRUB_HIDDEN_TIMEOUT_QUIET=/GRUB_HIDDEN_TIMEOUT_QUIET=true/' /etc/default/grub
update-grub
