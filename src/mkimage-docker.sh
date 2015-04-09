#!/usr/bin/env bash
# Based on github.com/docker/docker/contrig/mkimage.sh
set -e

suite=trusty
dir="build/docker"
rootfsDir="$dir/rootfs"
( set -x; mkdir -p "$rootfsDir" )

# get path to "chroot" in our current PATH
chrootPath=$(type -P chroot)
rootfs_chroot() {
	# "chroot" doesn't set PATH, so we need to set it explicitly to something our new 
    # debootstrap chroot can use appropriately!
	PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
        "$chrootPath" "$rootfsDir" "$@"
}

# base install
( 
    set -x 
    debootstrap --include=ubuntu-minimal --components=main,universe $suite $rootfsDir http://archive.ubuntu.com/ubuntu
)
# Docker specifics
# prevent init scripts from running during install/update
echo >&2 "+ echo exit 101 > '$rootfsDir/usr/sbin/policy-rc.d'"
cat > "$rootfsDir/usr/sbin/policy-rc.d" <<-'EOF'
	#!/bin/sh

	# For most Docker users, "apt-get install" only happens during "docker build",
	# where starting services doesn't work and often fails in humorous ways. This
	# prevents those failures by stopping the services from attempting to start.

	exit 101
EOF
chmod +x "$rootfsDir/usr/sbin/policy-rc.d"

# prevent upstart scripts from running during install/update
(
	set -x
	rootfs_chroot dpkg-divert --local --rename --add /sbin/initctl
	cp -a "$rootfsDir/usr/sbin/policy-rc.d" "$rootfsDir/sbin/initctl"
	sed -i 's/^exit.*/exit 0/' "$rootfsDir/sbin/initctl"
)

# shrink a little, since apt makes us cache-fat (wheezy: ~157.5MB vs ~120MB)
( set -x; rootfs_chroot apt-get clean )

# this file is one APT creates to make sure we don't "autoremove" our currently
# in-use kernel, which doesn't really apply to debootstraps/Docker images that
# don't even have kernels installed
rm -f "$rootfsDir/etc/apt/apt.conf.d/01autoremove-kernels"

# install dpkg tweaks
cp src/provision/apt.conf.d/* "$rootfsDir/etc/apt/apt.conf.d/"

# add the updates and security repositories
(
    set -x
    sed -i "
        p;s/ $suite / ${suite}-updates /; p;
        s/ $suite-updates / ${suite}-security /
    " "$rootfsDir/etc/apt/sources.list"
)

(
	set -x
	# make sure we're fully up-to-date
	rootfs_chroot sh -xc 'apt-get update && apt-get dist-upgrade -y'
	# delete all the apt list files since they're big and get stale quickly
	rm -rf "$rootfsDir/var/lib/apt/lists"/*
	# this forces "apt-get update" in dependent images, which is also good
)


# Docker mounts tmpfs at /dev and procfs at /proc so we can remove them
rm -rf "$rootfsDir/dev" "$rootfsDir/proc"
mkdir -p "$rootfsDir/dev" "$rootfsDir/proc"

# make sure /etc/resolv.conf has something useful in it
mkdir -p "$rootfsDir/etc"
cat > "$rootfsDir/etc/resolv.conf" <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

tarFile="$dir/rootfs.tar.xz"
touch "$tarFile"

(
	set -x
	tar --numeric-owner -caf "$tarFile" -C "$rootfsDir" --transform='s,^./,,' .
)

( set -x; rm -rf "$rootfsDir" )
