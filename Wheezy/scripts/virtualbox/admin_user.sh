#!/bin/bash


#
echo "Allowing the admin user to use sudo without a password."
cat > /etc/sudoers.d/99_admin <<EOF
$username ALL=(ALL) NOPASSWD:ALL
EOF
chmod 440 /etc/sudoers.d/99_admin

#
echo "Retrieving the SSH credentials and add to authorized keys for $username."
ssh_dir="/home/$username/.ssh"
authorized_keys="$ssh_dir/authorized_keys"

public_key=$(wget --no-check-certificate -qO - $public_key_url)
if [ -n "$public_key" ]; then
    if [ ! -f $authorized_keys ]; then
        if [ ! -d $ssh_dir ]; then
            mkdir -pm 700 $ssh_dir
            chown $username:$username $ssh_dir
        fi
        touch $authorized_keys
        chown $username:$username $authorized_keys
    fi

    if ! grep -s -q "$public_key" $authorized_keys; then
        printf "\n%s" -- "$public_key" >> $authorized_keys
        echo "New ssh key added to $authorized_keys from $public_key_url"
        chmod 600 $authorized_keys
        chown $username:$username $authorized_keys
    fi
fi
