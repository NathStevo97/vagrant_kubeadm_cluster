box-build:
	@packer build ./packer/ubuntu.pkr.hcl

box-init:
	@vagrant box add ubuntu-22-vmware-k8s .\ubuntu-22.04-x86_64.vmware.box

cluster-up:
	@vagrant up

cluster-pause:
	@vagrant suspend