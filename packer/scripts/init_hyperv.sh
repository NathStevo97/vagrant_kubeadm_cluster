#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get clean all -y
apt-get update -y
apt-get install pv perl mc net-tools -y

echo "Provisioning phase 1 - system updates"
export DEBIAN_FRONTEND=noninteractive
apt-get -y -q upgrade
apt-get -y -q clean all

echo "Provisioning phase 1 - disabling SELinux"
if [ -f /etc/sysconfig/selinux ]; then
  sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'||true
fi

if [ -f /etc/selinux/config ]; then
  sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'||true
fi

echo "Provisioning phase 1 - all done"

echo "Provisioning phase 3 - Starting: Extra packages, timezones, neofetch, firewalld, settings"
# misc
echo "Provisioning phase 3 - Timezone"
timedatectl set-timezone UTC --no-ask-password

echo "Provisioning phase 3 - Extra Packages or groups"
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install htop atop iftop iotop nmap nmon jq parted pv neofetch screen telnet ncdu multitail smartmontools zsh httpie
apt-get install -y linux-cloud-tools-virtual||true #may fail on arm64, add check for arm64

echo "Provisioning phase 3 - Hyper-V/SCVMM Daemons"
# Hyper-v daemons
export DEBIAN_FRONTEND=noninteractive
apt-get -y install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual
systemctl enable hv-fcopy-daemon
systemctl enable hv-kvp-daemon
systemctl enable hv-vss-daemon