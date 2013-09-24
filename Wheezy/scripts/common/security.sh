#!/bin/bash -x


# Security ----------------------------------------------------------------- #

#
echo "Enabling privileged access to hashed passwords."
shadowconfig on

#
echo "Disabling SSH password authentication."
sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

#
echo "Disabling SSH remote host name lookup."
cat >> /etc/ssh/sshd_config <<EOF
UseDNS no
EOF

#
echo "Disabling SSH login for root."
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
