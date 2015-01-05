.PHONY: build install remove clean
.DEFAULT_GOAL := build

src/output-virtualbox-iso/trusty64.ovf:
	@cd src && packer build packer-virtualbox-iso.json

build/trusty64_virtualbox.box: src/output-virtualbox-iso/trusty64.ovf
	@cd src && packer build packer-virtualbox-ovf.json

build/trusty64_libvirt.box:
	@cd src && packer build packer-qemu.json

build: build/trusty64_virtualbox.box build/trusty64_libvirt.box

install:
	@cd build && vagrant box add metadata.json

remove:
	@vagrant box remove iknite/trusty64 --provider=libvirt
	@vagrant box remove iknite/trusty64 --provider=virtualbox

clean:
	@rm -rf build/trusty64_*.box src/output-virtualbox-iso
