# -*- mode: ruby -*-
# vi: set ft=ruby :

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 1

#IP_NW = "192.169.56."
IP_NW = "192.169.190."
MASTER_IP_START = 1
NODE_IP_START = 2

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.box = "ubuntu-22-hyperv-k8s"
  config.ssh.username = "ubuntu"
  config.vm.provider :hyperv
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessable to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  # Provision Master Nodes
  (1..NUM_MASTER_NODE).each do |i|
    #config.vm.provider "hyperv" do |hv|
    #  hv.vmx["ethernet0.pcislotnumber"] = "33"
    #end
    config.vm.define "kubemaster" do |node|
      # Name shown in the GUI
      node.vm.provider "hyperv" do |hv|
          #hv.hostname = "kubemaster"
          hv.vmname = 'kubemaster'
          hv.memory = 2048
          hv.cpus = 2
          #hv.gui = false
      end
      node.vm.hostname = "kubemaster"
      node.vm.network "private_network", bridge: "Default Switch"
      node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"

      node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
        s.args = ["enp0s8"]
      end

      node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
    end
end


# Provision Worker Nodes
(1..NUM_WORKER_NODE).each do |i|
  #config.vm.provider "hyperv" do |hv|
  #  hv.vmx["ethernet0.pcislotnumber"] = "33"
  #end
  config.vm.define "kubenode0#{i}" do |node|
      node.vm.provider "hyperv" do |hv|
          #hv.hostname = "kubenode0#{i}"
          hv.vmname = "kubenode0#{i}"
          hv.memory = 2048
          hv.cpus = 2
          #hv.gui = false
      end
      node.vm.hostname = "kubenode0#{i}"
      node.vm.network "private_network", bridge: "Default Switch"
      node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
              node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

      node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
        s.args = ["enp0s8"]
      end

      node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
  end
end
end