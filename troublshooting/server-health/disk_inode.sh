#!/bin/bash

# Flag to track if any mount point exceeds 75%
echo "OK" > inode_usage.txt
# Get the usage percentage for each mount point
df -iP --exclude-type=tmpfs --exclude-type=devtmpfs | sort -k5 | awk 'NR>1 {print $5}' | grep -v '-' | while read -r usage; do
    # Remove the '%' character from the usage percentage
    usage="${usage%\%}"

    # Check if usage is less than 75%
    if (( usage > 75 )); then
        echo "NOT OK" > inode_usage.txt
    fi
done
