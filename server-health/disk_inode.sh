#!/bin/bash
rm -rf inode_usage.txt inode_detailed_usage.txt
output_file="inode_detailed_usage.txt"
# Flag to track if any mount point exceeds 75%
echo "OK" > inode_usage.txt
df -iT --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs | awk 'NR==1 || $5+0 > 75' | while read -r line; do
  echo "$line"
  mount_point=$(echo "$line" | awk '{print $7}')
  usage1=$(echo "$line" | awk '{print $6}')
  usage="${usage1%\%}"
  if (( usage > 2 )); then
            echo "NOT OK (>75)" > inode_usage.txt
			echo "Detailed inode usage for $mount_point:" >> $output_file
            find "$mount_point" -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n | tail -10  >> $output_file
    fi
done
