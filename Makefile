.PHONY: build install remove

build: 
	@packer build trusty64.json

install:
	@cd build && vagrant box add metadata.json

remove: 
	@vagrant box remove iknite/trusty64

