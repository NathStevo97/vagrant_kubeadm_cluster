
variable "ServerBaseVersion" {
  type    = string
  default = "22.04.3"
}

variable "boot_command" {
  type    = list(string)
  default = []
}

variable "boot_wait" {
  type    = string
  default = "10s"
}

variable "box_tag" {
  type    = string
  default = "natstephenson15/ubuntu-22-kubernetes"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "70000"
}

variable "disk_additional_size" {
  type    = list(number)
  default = ["1024"]
}

variable "http_directory" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = "file:https://releases.ubuntu.com/jammy/SHA256SUMS"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "non_gui" {
  type    = string
  default = "true"
}

variable "output_directory" {
  type    = string
  default = "~/.vagrant.d/boxes"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "switch_name" {
  type    = string
  default = ""
}

variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANT_CLOUD_TOKEN")}"
}

variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

locals {
  file         = "http://releases.ubuntu.com/22.04/ubuntu-${var.ServerBaseVersion}-live-server-amd64.iso"
  osdetails    = "ubuntu-${local.vboxversion}-amd64"
  os_name      = "ubuntu"
  os_arch      = "x86_64"
  vboxversion  = "${var.ServerBaseVersion}"
  version      = "${local.timestamp}"
  os_version   = "22.04"
  version_desc = "Latest kernel build of Ubuntu Vagrant images based on Ubuntu Server ${local.vboxversion} LTS (Jammy Jellyfish)"
}

source "hyperv-iso" "ubuntu-k8s-box" {
  boot_command          = "${var.boot_command}"
  boot_wait             = "${var.boot_wait}"
  communicator          = "ssh"
  cpus                  = "${var.cpu}"
  disk_block_size       = "1"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  headless              = "${var.non_gui}"
  http_directory        = "./packer/http"
  iso_checksum          = "${var.iso_checksum}"
  iso_url               = "${local.file}"
  #output_directory        = "${var.output_directory}"
  shutdown_command        = "echo 'password' | sudo -S shutdown -P now"
  ssh_handshake_attempts  = "1000"
  ssh_keep_alive_interval = "90s"
  ssh_password            = "${var.ssh_password}"
  ssh_timeout             = "6h"
  ssh_username            = "${var.ssh_username}"
  ssh_wait_timeout        = "6h"
  switch_name           = "${var.switch_name}"
  vm_name                 = "vagrant-ubuntu-${local.vboxversion}-amd64"
}

build {
  sources = ["source.hyperv-iso.ubuntu-k8s-box"]

  provisioner "shell" {
    execute_command   = "echo 'password' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "./packer/scripts/init_hyperv.sh",
      "./packer/scripts/uefi.sh"
    ]
  }

  provisioner "shell" {
    execute_command   = "echo 'password' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = [
      "./packer/scripts/motd.sh",
      "./packer/scripts/networking.sh",
      "./packer/scripts/sudoers.sh",
      "./packer/scripts/vagrant.sh",
      "./packer/scripts/ansible.sh",
      "./packer/scripts/cleanup.sh",
      "./packer/scripts/minimize.sh"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "./packer/scripts/node_setup.yaml"
  }


  post-processors {

    post-processor "vagrant" {
      keep_input_artifact = false
      compression_level   = 9
      provider_override   = "hyperv"
      output               = "${path.root}/${local.os_name}-${local.os_version}-${local.os_arch}.{{ .Provider }}.box"
      }

    #post-processor "vagrant-cloud" {
    #  access_token        = "${var.vagrantcloud_token}"
    #  box_tag             = "${var.box_tag}"
    #  version             = "${local.vboxversion}-${local.version}"
    #  version_description = "${local.version_desc}"
    #}
  }
}
