#!/bin/bash -x


# Network ------------------------------------------------------------------ #

#
echo "Removing resolv.conf."
rm -f /etc/resolv.conf

#
echo "configuring network interfaces."
sed -i -e 's/^allow-hotplug eth0/auto eth0/' /etc/network/interfaces

#
#echo "Configuring the DHCP client."
#sed -i "s/^#*SET_DNS=.*/SET_DNS=\'yes\'/" /etc/default/dhcpcd

#
echo "Removing leftover leases and persistent rules."
rm /var/lib/dhcp/*
