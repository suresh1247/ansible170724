#!/bin/bash

# Flag to track if any mount point exceeds 75%
echo "OK" > df_usage.txt
# Get the usage percentage for each mount point
df -h | sort -k5 | awk 'NR>1 {print $5}' | while read -r usage; do
    # Remove the '%' character from the usage percentage
    usage="${usage%\%}"

    # Check if usage is less than 75%
    if (( usage > 75 )); then
        echo "NOT OK" > df_usage.txt
    fi
done

