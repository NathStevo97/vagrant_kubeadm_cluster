box-build:
	@packer init -upgrade "./packer/required_plugins.pkr.hcl"
	@packer build -var-file="./packer/variables.pkrvars.hcl" "./packer/ubuntu.pkr.hcl"

box-init:
	@vagrant box add ubuntu-22-hyperv-k8s .\ubuntu-22.04-x86_64.hyperv.box

cluster-start:
	@vagrant up

cluster-up:
	@vagrant resume

cluster-down:
	@vagrant suspend

cluster-reload:
	@vagrant suspend && vagrant resume