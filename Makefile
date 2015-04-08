.PHONY: build docker vagrant
.DEFAULT_GOAL := build

guard-%:
	@if [ "${${*}}" == "" ]; then echo -e "\nERROR: variable $* not set\n" && exit 1; fi

build/vagrant/trusty64_virtualbox.box:
	@packer build -only=virtualbox-iso src/packer.json

build/vagrant/trusty64_libvirt.box:
	@packer build -only=qemu src/packer.json

build/vagrant/trusty64_docker.box:
	@packer build -only=docker src/packer.json

build/docker/rootfs.tar.xz:
	@sudo ./src/mkimage-docker.sh

build:  build/docker/rootfs.tar.xz \
	build/vagrant/trusty64_virtualbox.box \
	build/vagrant/trusty64_libvirt.box

docker: build/docker/rootfs.tar.xz guard-VERSION
	@docker build -t iknite/trusty64:${VERSION} build/docker

vagrant:
	@cd build/vagrant && vagrant box add metadata.json

clean: 
	@rm -f build/vagrant/trusty64_*.box build/docker/rootfs*

