#!/bin/bash
set -x

# sudo install requiered dependencies
apt-get install -y -qq linux-headers-generic build-essential dkms nfs-common > /dev/null

# install virtualbox guest additions
# mount iso
mkdir /tmp/isomount
mount -t iso9660 -o loop /tmp/VBoxGuestAdditions.iso /tmp/isomount

# Install the drivers
/tmp/isomount/VBoxLinuxAdditions.run

# Cleanup
umount /tmp/isomount
rm -rf /tmp/isomount /tmp/VBoxGuestAdditions.iso
