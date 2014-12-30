#! /usr/bin/env bash

# Updating and Upgrading dependencies
apt-get update -y -qq > /dev/null
apt-get dist-upgrade -y -qq > /dev/null

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant

# vagrant user needs sudo without ask password, yikes
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

install_vbox(){
    # install virtualbox guest additions
    # mount iso
    mkdir /tmp/isomount
    mount -t iso9660 -o loop /root/VBoxGuestAdditions.iso /tmp/isomount

    # Install the drivers
    /tmp/isomount/VBoxLinuxAdditions.run

    # Cleanup
    umount /tmp/isomount
    rm -rf /tmp/isomount /root/VBoxGuestAdditions.iso
}
[[ -z /root/VBoxGuestAdditions.iso ]] && install_vbox
