#!/bin/bash -x


# Cleanup ------------------------------------------------------------------ #

#
echo "Clearing the MOTD."
> /var/run/motd

#
echo "Removing temporary files."
rm -rf \
    /var/log/{bootstrap,dpkg}.log \
    /tmp/*
if [ -f /root/.bash_history ]; then
    shred --remove /root/.bash_history
fi


# Apt ---------------------------------------------------------------------- #

#
echo "Removing unused packages."
apt-get autoremove --purge

#
echo "Clearing the aptitude cache."
apt-get clean

#
echo "Re-enabling daemon autostart."
rm -rf /usr/sbin/policy-rc.d
