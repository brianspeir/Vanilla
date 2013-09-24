#!/bin/bash -x


# Apt ---------------------------------------------------------------------- #

#
echo "Adding aptitude sources."
> /etc/apt/sources.list

cat >> /etc/apt/sources.list <<EOF
deb http://ftp.us.debian.org/debian/ wheezy main
deb-src http://ftp.us.debian.org/debian/ wheezy main

deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main
EOF

#
echo "Disabling daemon autostart."
cat > /usr/sbin/policy-rc.d <<EOF
#!/bin/sh
exit 101
EOF
chmod 755 /usr/sbin/policy-rc.d

#
echo "Upgrading packages and fixing broken dependencies."
apt-get update
apt-get --fix-broken --assume-yes install
apt-get --assume-yes upgrade
