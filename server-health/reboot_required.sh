#!/bin/bash
echo "OK (Reboot is not required)" > reboot_required.txt
reboot_check_debian() {
current_kernel=$(uname -r | sed 's/azure\|generic\|-//g')

latest_installed_kernel=$(dpkg -l | grep linux-image | awk '{print $2}' | sed 's/linux-image-\|generic\|azure\|-//g' | sort -V | tail -n1)

if [ "$current_kernel" != "$latest_installed_kernel" ]; then

  echo "NOT OK (Reboot is required)" > reboot_required.txt
else
  echo "OK (Reboot is not required)" > reboot_required.txt
fi
}

reboot_check_redhat() {

if [ "$(rpm -q --last kernel | head -1 | awk '{print $1}')" != "$(uname -r)" ]; then
  echo "NOT OK (Reboot is required)" > reboot_required.txt
else
  echo "OK (Reboot is not required)" > reboot_required.txt
fi
}


reboot_check_suse() {
if [ -f "/var/run/reboot-required" ]; then
    echo "NOT OK (Reboot is required)"  > reboot_required.txt
else
    echo "OK (Reboot is not required)" > reboot_required.txt
fi
}

# Detect the operating system and call the appropriate function
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            reboot_check_debian
            ;;
        rhel|centos|fedora)
            reboot_check_redhat
            ;;
        opensuse|suse|sles)
            reboot_check_suse
            ;;
        *)
            echo "Unsupported OS: $ID" > reboot_required.txt
            ;;
    esac
else
    echo "Cannot determine the operating system." > reboot_required.txt
fi
