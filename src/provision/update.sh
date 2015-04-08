#!/bin/bash
set -x

# configure tweaks
mv /tmp/docker-* /etc/apt/apt.conf.d
chown root:root /etc/apt/apt.conf.d/docker-*
chmod 644 /etc/apt/apt.conf.d/docker-*

# make sure we're fully up-to-date
apt-get update && apt-get dist-upgrade -y

reboot
