#!/bin/bash
rm -rf detailed_disk_usage.txt
output_file="detailed_disk_usage.txt"
# Flag to track if any mount point exceeds 75%
echo "OK" > df_usage.txt
# Get the usage percentage for each mount point
df -h  --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs | sort -k5 | awk 'NR>1 {print $5}' | while read -r usage; do
    # Remove the '%' character from the usage percentage
    usage="${usage%\%}"

    # Check if usage is less than 75%
    if (( usage > 75 )); then
        echo "NOT OK" > df_usage.txt
    fi

    if (( usage > 75 )); then
echo -e 'mount points which are consuming more than 75% from the server and their detaile usage: ' >> $output_file
df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs | awk '$5 > "75%"' >> $output_file
echo -e "###########################################################\n" >> $output_file
df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs | awk '$5+0 > 75 {print $6}' | xargs -I{} sh -c 'echo "Mount point: {}"; du -h {} 2>/dev/null | grep ^[0-9.]*G | sort -nr' >> $output_file
echo -e "###################  CMD: df -hT  ##################################\n" >> $output_file
df -hT >> $output_file

echo -e "###########################################################\n\n" >> $output_file
echo -e '\n CMD detailed disk usage in server : \n' >> $output_file
du -h / | grep ^[0-9.]*G | sort -nr >> $output_file

echo -e "###########################################################\n" >> $output_file
echo -e ' fstab entries & samba shares information ' >> $output_file
cat /etc/fstab >> $output_file
cat /etc/exports >> $output_file
    fi
done

