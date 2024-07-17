#!/bin/bash
echo "OK (Not Required)" > reboot_required.txt
# Check if reboot is required in Red Hat
#if [ -x "$(command -v needs-restarting)" ] && [ "$(needs-restarting -r)" == "Reboot is needed" ]; then
#    echo "NOT OK (Reboot is required)"  > reboot_required.txt
#else
#    echo "OK (Not Required)" > reboot_required.txt
#fi
if [ "$(rpm -q --last kernel | head -1 | awk '{print $1}')" != "$(uname -r)" ]; then
  echo "NOT OK (Reboot is required)" > reboot_required.txt
else
  echo "OK (Not Required)" > reboot_required.txt
fi

# Check if reboot is required in Ubuntu
if [ -f "/var/run/reboot-required" ]; then
    echo "NOT OK (Reboot is required)"  > reboot_required.txt
else
    echo "OK: (Not Required)" > reboot_required.txt
fi

# Check if reboot is required in SUSE
if [ -f "/var/run/reboot-required" ]; then
    echo "NOT OK (Reboot is required)"  > reboot_required.txt
else
    echo "OK (Not Required)" > reboot_required.txt
fi

