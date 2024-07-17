#!/bin/bash

# Function to check updates on Debian/Ubuntu
check_updates_debian() {
    sudo apt-get update > /dev/null 2>&1
#    if apt-get -s upgrade | grep -i "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded."; then
   # if apt list --upgradable | grep -i "All packages are up to date"; then
output=$(apt-get -s upgrade | grep -i "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded." | wc -l)

# Check if the output is 1, indicating compliance
    if [ "$output" -eq 1 ]; then 
        echo "Server is up-to-date :  Non-Compliance"
    else
        echo "Updates available: Compliance"
    fi
}

# Function to check updates on RHEL/CentOS
check_updates_redhat() {
    if sudo yum check-update > /dev/null 2>&1; then
        if [ $? -eq 0 ]; then
            echo "Server is up-to-date :  Non-Compliance"
        else
            echo "Updates available: Compliance"
        fi
    else
        echo "Updates available: Compliance"
    fi
}

# Function to check updates on SUSE
check_updates_suse() {
    sudo zypper refresh > /dev/null 2>&1
    if sudo zypper lu | grep -q "No updates found."; then
	    echo "Server is up-to-date :  Non-Compliance "
    else
	    echo "Updates available: Compliance"
    fi
}

# Detect the operating system and call the appropriate function
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            check_updates_debian
            ;;
        rhel|centos|fedora)
            check_updates_redhat
            ;;
        opensuse|suse|sles)
            check_updates_suse
            ;;
        *)
            echo "Unsupported OS: $ID"
            ;;
    esac
else
    echo "Cannot determine the operating system."
fi

