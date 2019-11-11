#!/bin/bash

# 8GB swap file setup 
# Source Ref: https://support.rackspace.com/how-to/create-a-linux-swap-file/
# TODO Parameterize memory size
set -e

# Swapiness config
# swapiness values: 0-100
# 0 = swap is used when system is completely out of memory
# Higher values enable system to swap idel prcoesses
SWAPINESS=60 # typical value

echo 'Create swap file and formating'
sudo fallocate -l 8G /mnt/8GB.swap # Create swap file
sudo mkswap /mnt/8GB.swap # Format file
sudo swapon /mnt/8GB.swap # Add to filesystem as swap

echo 'Mounting swap file on boot'
# <file system> <mount point> <type> <options> <dump> <pass>
echo '/mnt/8GB.swap none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null

echo "Adding swapiness, $SWAPINESS, to sysctl.conf"
echo "vm.swappiness=$SWAPINESS" | sudo tee -a /etc/sysctl.conf > /dev/null

# Show swap status
sudo swapon -s

echo '/mnt/8GB.swap should be active above - Restart Device'
