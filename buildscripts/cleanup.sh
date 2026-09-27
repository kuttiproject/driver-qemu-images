#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Clean Up
echo "==> Cleaning up"

echo "Removing unneeded software..."
## We do not need the following packages:
##   vim-tiny 
##   installation-report
apt-get purge -y vim-tiny installation-report perl
echo "Done."

## The "laptop" tasksel task seems to be autoselected for whatever reason.
## Remove it while ignoring errors
echo "Trying to remove *laptop* tasksel task..."
tasksel remove laptop && echo "Done." || echo "Laptop task could not be removed."

## Apt autoremove for all residual stuff
echo "Autoremoving unneeded software..."
apt-get autoremove --purge -y
echo "Done."

echo "Cleaning APT caches and logs..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /tmp/* /var/tmp/* /var/log/*.log /var/log/journal/*
