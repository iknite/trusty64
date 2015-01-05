.PHONY: build install remove clean

src/virtualbox-iso/output-virtualbox-iso/trusty64.ovf:
	@cd src/virtualbox-iso && packer build packer.json

build/trusty64_virtualbox.box:
	@cd src/virtualbox-ovf && packer build packer.json

build/trusty64_libvirt.box:
	@cd src/qemu && packer build packer.json

build:  src/virtualbox-iso/output-virtualbox-iso/trusty64.ovf build/trusty64_virtualbox.box build/trusty64_libvirt.box

install:
	@cd build && vagrant box add metadata.json

remove: 
	@vagrant box remove iknite/trusty64 --provider=libvirt
	@vagrant box remove iknite/trusty64 --provider=virtualbox

clean: 
	@rm -rf build/trusty64_*.box src/virtualbox-iso/output-virtualbox-iso

all: build install

