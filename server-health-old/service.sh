#!/bin/bash

netstat -ntlp
printf " \n \n "

# Get the list of running services
services=$(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}')

# Loop through each service and get its uptime
for service in $services; do
    uptime=$(systemctl show -p ActiveEnterTimestamp --value $service)
    printf "%-30s %s\n" "$service" "$uptime"
done
