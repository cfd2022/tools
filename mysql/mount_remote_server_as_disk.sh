#!/bin/bash

# Function to trim whitespace
trim() {
    echo "$1" | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Prompt the user for remote server information
read -p "Enter the remote server host (IP or domain): " remote_host
remote_host=$(trim "$remote_host")

read -p "Enter the remote server username: " remote_user
remote_user=$(trim "$remote_user")

read -p "Enter the remote server password (visible): " remote_password
remote_password=$(trim "$remote_password")

read -p "Enter the remote directory path (e.g., /path/to/remote/directory): " remote_dir
remote_dir=$(trim "$remote_dir")

# Set default local mount path based on remote host
default_local_mount="/mnt/$remote_host"
read -p "Enter the local mount path [default: $default_local_mount]: " local_mount
local_mount=$(trim "${local_mount:-$default_local_mount}")

# Install sshpass and sshfs if they are not installed
if ! command -v sshpass &> /dev/null || ! command -v sshfs &> /dev/null; then
    echo "Installing sshpass and sshfs..."
    sudo apt-get update
    sudo apt-get install -y sshpass sshfs
fi

# Create the local mount point
echo "Creating local mount directory..."
sudo mkdir -p "$local_mount"

# Confirm mount configuration
echo ""
echo "Please confirm the following configuration:"
echo "Remote server: $remote_host"
echo "Remote username: $remote_user"
echo "Remote password: $remote_password"
echo "Remote directory path: $remote_dir"
echo "Local mount path: $local_mount"
read -p "Is this information correct? [y/n]: " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Operation canceled."
    exit 1
fi

# Execute the mount command
echo "Mounting remote directory to local path..."
sshpass -p "$remote_password" sshfs -o UserKnownHostsFile=/dev/null,StrictHostKeyChecking=no,big_writes,cache=yes "$remote_user@$remote_host:$remote_dir" "$local_mount"

# Verify if the mount was successful
if mount | grep -q "$local_mount"; then
    echo "Remote directory successfully mounted at $local_mount"
else
    echo "Mount failed, please check the configuration."
fi
