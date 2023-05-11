
variable "ServerBaseVersion" {
  type    = string
  default = "22.04.2"
}

variable "box_tag" {
  type    = string
  default = "nitindas/ubuntu-22"
}

variable "checksum" {
  type    = string
  default = "file:https://releases.ubuntu.com/jammy/SHA256SUMS"
}

variable "non_gui" {
  type    = string
  default = "true"
}

variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANT_CLOUD_TOKEN")}"
}

variable "output_directory" {
  type    = string
  default = "c:/vagrant-box"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

locals {
  file         = "http://releases.ubuntu.com/22.04/ubuntu-${var.ServerBaseVersion}-live-server-amd64.iso"
  osdetails    = "ubuntu-${local.vboxversion}-amd64"
  vboxversion  = "${var.ServerBaseVersion}"
  version      = "${local.timestamp}"
  version_desc = "Latest kernel build of Ubuntu Vagrant images based on Ubuntu Server ${local.vboxversion} LTS (Jammy Jellyfish)"
}

# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "vmware-iso" "packer-vagrant-ubuntu-virtual-box" {
  # boot_command = [
  #   "<wait>c<wait>set gfxpayload=keep<enter><wait>linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ---<enter><wait>initrd /casper/initrd<wait><enter><wait>boot<enter><wait>"
  # ]

  boot_command = [
    "<wait>c<wait>",
    "set gfxpayload=keep<enter><wait>",
    # "linux /casper/vmlinuz autoinstall quiet ds='nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/' ---<enter><wait>",
    "linux /casper/vmlinuz autoinstall ds='nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/' ---<enter><wait>",
    "initrd /casper/initrd<wait><enter><wait>",
    "boot<enter><wait>"
  ]

  # boot_command = [
  #   "<wait>c<wait>",
  #   "set gfxpayload=keep<enter><wait>",
  #   "linux /casper/vmlinuz <wait>",
  #   "autoinstall quiet fsck.mode=skip <wait>",
  #   "ipv6.disable=1 net.ifnames=0 biosdevname=0 systemd.unified_cgroup_hierarchy=0 ds='nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/' ---<enter><wait>",
  #   "initrd /casper/initrd<wait><enter><wait>",
  #   "boot<enter><wait>"
  # ]

  # boot_command = [
  #   "<wait>c<wait>",
  #   "set gfxpayload=keep<enter><wait>",
  #   "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/'<enter><wait>",
  #   "initrd /casper/initrd<wait><enter><wait>",
  #   "boot<enter>",
  #   "<enter><f10><wait>"
  # ]

  # boot_command = [
  #   "<wait>c<wait>",
  #   "set gfxpayload=keep<enter><wait>",
  #   "linux /casper/vmlinuz autoinstall ds='nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/' ---<enter><wait>",
  #   "initrd /casper/initrd<wait><enter><wait>",
  #   "boot<enter>",
  #   "<enter><f10><wait>"
  # ]

  boot_wait               = "5s"
  http_directory          = "./packer/http"
  #guest_additions_path    = "VBoxGuestAdditions_{{.Version}}.iso"
  guest_os_type           = "ubuntu-64"
  headless                = "${var.non_gui}"
  iso_checksum            = "${var.checksum}"
  iso_url                 = "${local.file}"
  #memory                  = 4096
  disk_size               = 50000
  #output_directory        = "c:/vagrant-box"
  shutdown_command        = "echo 'vagrant'|sudo -S shutdown -P now"
  ssh_handshake_attempts  = "1000"
  ssh_keep_alive_interval = "90s"
  ssh_password            = "vagrant"
  ssh_timeout             = "90m"
  ssh_username            = "vagrant"
  ssh_wait_timeout        = "6h"
  #virtualbox_version_file = ".vbox_version"
  vmx_data = {
    memsize = "2048"
    numvcpus = "2"
  }
  vm_name                 = "packer-vagrant-ubuntu-${local.vboxversion}-amd64"
}

build {
  sources = ["source.vmware-iso.packer-vagrant-ubuntu-virtual-box"]

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = [
      "./packer/scripts/update.sh",
      "./packer/scripts/motd.sh",
      "./packer/scripts/networking.sh",
      "./packer/scripts/sudoers.sh",
      "./packer/scripts/vagrant.sh",
      "./packer/scripts/cleanup.sh",
      "./packer/scripts/minimize.sh",
      "./packer/scripts/node_setup.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      compression_level   = 9
      }
    }
  /*
    post-processor "vagrant-cloud" {
      access_token        = "${var.vagrantcloud_token}"
      box_tag             = "${var.box_tag}"
      version             = "${local.vboxversion}-${local.version}"
      version_description = "${local.version_desc}"
    }
  */
}
