# Network ------------------------------------------------------------------ #

echo "Cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up."
cat >> /etc/network/interfaces <<EOF

# To make the dhclient happy
pre-up sleep 2
EOF
