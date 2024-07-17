#/bin/bash
rm -rf testing/debug_output* testing/detailed_output*
ansible-playbook -i inventory main.yml

cat testing/debug_output* | sed '$!s/$/\n/' >> testing/detailed_output.csv
rm -rf testing/debug_output*

