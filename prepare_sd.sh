#!/bin/bash

################################################################################
# AUTOMATED LINUX SD CARD PREPARATION SCRIPT FOR ZYNQBERRY PETALINUX
# Run this script on your Linux Host machine (Ubuntu)
################################################################################

# --- CONFIGURATION VARIABLES ---
# CHANGE THIS TO MATCH YOUR TARGET DRIVE (Check via 'lsblk' first!)
TARGET_DRIVE="/dev/sdb" 

# PATH TO YOUR PETALINUX OUTPUT IMAGES DIRECTORY
IMAGES_DIR="./images/linux"

# --- SAFETY CHECK ---
echo "================================================================="
echo "!!! WARNING: ALL DATA ON ${TARGET_DRIVE} WILL BE PERMANENTLY ERASED !!!"
echo "================================================================="
read -p "Are you absolutely sure ${TARGET_DRIVE} is your MicroSD card? (y/N): " confirm
if [[ $confirm != "[yY]" && $confirm != "y" ]]; then
    echo "Operation cancelled by user."
    exit 1
fi

# Ensure target images exist before starting formatting sequence
if [ ! -f "${IMAGES_DIR}/zImage" ] || [ ! -f "${IMAGES_DIR}/system.dtb" ] || [ ! -f "${IMAGES_DIR}/rootfs.tar.gz" ]; then
    echo "ERROR: Required build files (zImage, system.dtb, rootfs.tar.gz) not found in ${IMAGES_DIR}."
    exit 1
fi

echo "Unmounting any existing partitions on ${TARGET_DRIVE}..."
sudo umount ${TARGET_DRIVE}* 2>/dev/null

# --- STEP 1 & 2: WIPE AND PARTITION THE CARD ---
echo "Partitioning ${TARGET_DRIVE}..."
# Using fdisk automated via standard input redirect
# d = delete, n = new, p = primary, 1 = part 1, +60M = size, t = type, c = FAT32
# n = new, p = primary, 2 = part 2, defaults to remaining space, w = write
sudo fdisk ${TARGET_DRIVE} <<EOF
d
1
d
2
d
3
d
n
p
1

+60M
t
c
n
p
2


w
EOF

# --- STEP 3: FORMAT THE PARTITIONS ---
echo "Formatting partitions..."
# Format partition 1 as FAT32 named BOOT
sudo mkfs.vfat -F 32 -n BOOT ${TARGET_DRIVE}1

# Format partition 2 as EXT4 named rootfs
sudo mkfs.ext4 -F -L rootfs ${TARGET_DRIVE}2

# --- STEP 4: MOUNT THE PARTITIONS ---
echo "Creating temporary mount points and mounting partitions..."
mkdir -p /tmp/BOOT
mkdir -p /tmp/rootfs

sudo mount ${TARGET_DRIVE}1 /tmp/BOOT
sudo mount ${TARGET_DRIVE}2 /tmp/rootfs

# --- STEP 5: COPY PETALINUX OUTPUT FILES ---
echo "Copying Kernel image and Device Tree to BOOT partition..."
sudo cp ${IMAGES_DIR}/zImage /tmp/BOOT/
sudo cp ${IMAGES_DIR}/system.dtb /tmp/BOOT/

echo "Extracting Root Filesystem to rootfs partition (this may take a minute)..."
sudo tar -xvf ${IMAGES_DIR}/rootfs.tar.gz -C /tmp/rootfs/

# --- STEP 6: SAFELY UNMOUNT AND EJECT ---
echo "Flushing data cache buffers onto hardware..."
sync

echo "Unmounting partitions..."
sudo umount /tmp/BOOT
sudo umount /tmp/rootfs

# Clean up local system directories
rm -rf /tmp/BOOT
rm -rf /tmp/rootfs

echo "================================================================="
echo " SUCCESS: MicroSD Card successfully formatted and populated!"
echo " Safe to remove the card and insert into the ZynqBerry."
echo "================================================================="
