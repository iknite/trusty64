.PHONY: build install remove clean

src/virtualbox-iso/output-virtualbox-iso/trusty64.ovf:
	@cd src/virtualbox-iso && packer build packer.json

build/trusty64.box:
	@cd src/virtualbox-ovf && packer build packer.json

build:  src/virtualbox-iso/output-virtualbox-iso/trusty64.ovf build/trusty64.box

install:
	@cd build && vagrant box add metadata.json

remove: 
	@vagrant box remove iknite/trusty64

clean: 
	@rm -rf build/trusty64.box src/virtualbox-iso/output-virtualbox-iso

all: build install

