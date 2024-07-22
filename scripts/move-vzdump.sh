#!/bin/bash

# Define variables
BACKUP_PATH=""
DESTINATION_PATH="/mnt/pve/NFS/template/cache/current-lxc.tar.gz"

# Check if the backup file exists
if [ -f "$BACKUP_PATH" ]; then
    echo "Backup file found: $BACKUP_PATH"
    
    # Move the file to the destination, overwriting any existing file
    mv "$BACKUP_PATH" "$DESTINATION_PATH"
    
    if [ $? -eq 0 ]; then
        echo "File moved successfully to $DESTINATION_PATH"
    else
        echo "Failed to move file."
        exit 1
    fi
else
    echo "Backup file not found: $BACKUP_PATH"
    exit 1
fi
