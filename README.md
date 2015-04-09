Trusty64 images
===============


Simple Base images for a true minimal Ubuntu 14.04.2 64Bits

This is the source files for: 

* `iknite/trusty64` in [atlas](//atlas.hashicorp.com/iknite/boxes/trusty64) in both `libvirt` and `virtualbox` (for now)
* `iknite/trusty64` in [docker hub](//hub.docker.com/u/iknite/trusty64)

Rationale
---------
All the base images that I found always comes with something more than just the barebones. 

This one didn't. It does not contain man pages, build-essential meta packages and nothing else
than `openssh-server`.

Also make the common dpkg tweaks found in docker like faster installs, 
auto cache clean after installs and keep the index of the downloads.

Requirements
------------

* packer-io
* debootstrap

Usage
-----

* `make` to run both builders (debootstrap+ssh & packer).
* `make vagrant` to locally install the boxes.
* `make docker` to locally install the container. 

Manual Usage
------------

### Docker

There's no other way to launch it than `sudo src/mkimage-docker.sh`


### Packer

Before run the command please make sure no `VT-x` consumer are in the **build machine**. Otherwise virtualbox tries to
trick you to kernel disable it. 

Running `packer build -parallel=false src/packer.json` will succesfuly built. 


#### Optional variables and their defaults:

```
  iso_checksum      = 83aabd8dcf1e8f469f3c72fff2375195
  iso_checksum_type = md5
  iso_url           = http://releases.ubuntu.com/14.04.2/ubuntu-14.04.2-server-amd64.iso
  ssh_password      = vagrant
  ssh_username      = vagrant
  vm_name           = trusty64
```

#### Builders:

  qemu          
  virtualbox-iso

#### Provisioners:

  * file: Copies `src/provision/apt.conf.d` to /tmp 
  * shell: `update.sh` moves /tmp/docker-* to /etc/apt/apt.conf-d/, dist-upgrade the machine and reboot
  * shell: `install-vagrant.sh` ensures vagrant can run in this machine
  * shell: `install-virtualbox.sh` installs the basics for virtualbox.

License
-------

3 clause BSD license
