#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Remove the standard kernel, because it has been replaced by the
# cloud kernel in step 1
echo "==> Removing standard kernel"
# apt-get purge -y linux-image-amd64 $(dpkg-query -f '${Package}\n' -W 'linux-image-*-amd64' | grep -v 'cloud')
dpkg-query -f '${Package}\n' -W 'linux-image-*-amd64' | grep -v 'cloud' | xargs -r apt-get purge -y linux-image-amd64
echo "Done."

# Update GRUB settings
echo "==> Updating GRUB settings"

## Set boot loader timeout to 0
echo "Seting boot loader timeout..."
sed -i 's/GRUB_TIMEOUT=\(.*\)/GRUB_TIMEOUT=0/g' /etc/default/grub;
echo "Done."

## Disable Predictable Network Interface names and use eth0

## This script disables "predictable interface names" like enp0s3,
## and restores the use of interface names like eth0.
## This seems to be needed if we use the virtualbox-ovf source,
## otherwise networking does not start on any VM created by the
## exported .ova file. The following issue gave the clue:
##   https://github.com/hashicorp/packer/issues/866
## and the solution was picked up from:
##   https://github.com/chef/bento/blob/master/packer_templates/debian/scripts/networking.sh
## The setting has been carried over into non-virtualbox drivers
## because it works well.

echo "Disabling predictable network interface names..."
## This script assumes that the names of all interfaces in
## /etc/network/interfaces will be replaced with eth0. This works
## for us, because we use only one interface connected to the
## standard network.
sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
## Add kernel parameter to disable predictable interface names
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="console=ttyS0 net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
echo "Done."

## Update grub
echo "Updating GRUB..."
update-grub;
echo "Done."

# Add/edit directories and files

echo "==> Adding/editing directories and files"

## Patch networking
## Replace the /etc/network/interfaces file completely, because 
## there seems to be a problem with VirtualBox 7 on Linux
## This approach has been carried forward to non-VirtualBox
## derivers because it works well.
cat >/etc/network/interfaces <<EOINTERFACES
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp

EOINTERFACES
## Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces

## Set up directory for later copying of kutti interface scripts
mkdir -p /opt/kutti/scripts
chown kuttiadmin:kuttiadmin /opt/kutti/scripts

## Set up basic motd
echo "Welcome to kutti." > /etc/motd

echo "Done."

# Add required system packages
echo "==> Adding required system packages"

apt-get update

echo "Installing ca-certificates, gpg, iptables, bash completion, socat, vim and curl..."
apt-get install -y ca-certificates gpg iptables apt-transport-https bash-completion socat vim curl
echo "Done."

# Add user1
echo "==> Adding user1"
adduser --gecos "User 1" --disabled-password user1
chpasswd <<EOPASSWD
user1:Pass@word1
EOPASSWD
adduser user1 sudo
echo "Done."
