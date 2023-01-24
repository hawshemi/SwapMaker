#!/bin/sh

# Argument checks
if [ ! "$#" -ge 1 ]; then
    echo "Usage: $0 {size}"
    echo "Example: $0 4G"
    echo "(Default path: /swapfile)"
    echo "Optional path: Usage: $0 {size} {path}"
    exit 1
fi


## Intro
echo 
echo "This script will automatically setup a swap file and enable it."
echo "Root access is required, please run as root or enter sudo password." 
echo "Source is @ https://github.com/hawshemi/swapmaker" 
echo 


## Setup Variables

# Get size from first argument
SWAP_SIZE=$1

# Get path from second argument (default to /swapfile)
SWAP_PATH="/swapfile"
if [ ! -z "$2" ]; then
    SWAP_PATH=$2
fi


## Run
sudo fallocate -l $SWAP_SIZE $SWAP_PATH  # Allocate size
sudo chmod 600 $SWAP_PATH                # Set proper permission
sudo mkswap $SWAP_PATH                   # Setup swap         
sudo swapon $SWAP_PATH                   # Enable swap
echo "$SWAP_PATH   none    swap    sw    0   0" | sudo tee -a /etc/fstab # Add to fstab


## Optimize Swap Settings

echo 'net.core.default_qdisc=fq' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | tee -a /etc/sysctl.conf
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
sysctl -p


## Outro

echo 
echo "Done! You now have a $SWAP_SIZE swap file at $SWAP_PATH"
echo 
