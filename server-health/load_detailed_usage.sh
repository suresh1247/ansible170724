
#/bin/bash
rm -rf load_usage.txt
output_file="load_usage.txt"
echo -e ' Top 7 processes which are consuming high CPU: \n' >> $output_file
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 7 >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e 'mount points which are consuming more than 75% from the server and their detaile usage: ' >> $output_file
df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs | awk '$5 > "75%"' >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e ' Processes which are consuming high memory in the server:' >> $output_file
top -o %MEM -b -n 1 | tail -n +4 | head -n 15 >> $output_file
echo -e "###################  uptime  #####################################\n" >> $output_file
uptime >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e '\n Memory usage using free command \n' >> $output_file
free -m  >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e ' \n Load on server: using sar report \n ' >> $output_file
sar -q >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e '\n last reboot information \n' >> $output_file
last | grep -i boot >> $output_file
echo -e '\n' >> $output_file 
echo -e "###########################################################\n" >> $output_file
echo -e 'last patch updated in server: \n' >> $output_file
ls -lt --time-style=long-iso /boot | grep vmlinuz | head -n 1 >> $output_file


