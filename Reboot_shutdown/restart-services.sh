#!/bin/bash

service_list_file="running_services.txt"

if [ ! -f "$service_list_file" ]; then
    echo "Error: $service_list_file not found."
    exit 1
fi

while IFS= read -r service_name; do
    if ! systemctl is-active --quiet "$service_name"; then
        echo "$service_name is not running. Restarting..." > restarted_services.txt
        systemctl restart "$service_name"
        if [ $? -eq 0 ]; then
            echo "$service_name has been restarted successfully." >> restarted_services.txt
        else
            echo "Failed to restart $service_name." >> restarted_services.txt
        fi
    fi
done < "$service_list_file"

if  [ ! -s restarted_services.txt ]; then
    echo "all services started with reboot" > restarted_services.txt
fi

