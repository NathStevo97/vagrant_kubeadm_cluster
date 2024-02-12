#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/ubuntu}";

sudo apt-add-repository ppa:ansible/ansible
echo "update the package list"
apt-get -y update;
apt install --assume-yes ansible

echo "upgrade all installed packages incl. kernel and kernel headers"
apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew";