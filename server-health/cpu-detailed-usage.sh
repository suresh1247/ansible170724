
#/bin/bash
rm -rf cpu_usage.txt
output_file="cpu_usage.txt"
echo -e "###########################################################\n" >> $output_file
echo -e ' Top 7 processes which are consuming high CPU: \n' >> $output_file
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 7 >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e '\n CPU usage using sar report\n' >> $output_file
sar >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e ' \n Load on server: using sar report \n ' >> $output_file
sar -q >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e 'kernel information \n' >> $output_file
uname -r >> $output_file
echo -e '\n' >> $output_file 
echo -e "###########################################################\n" >> $output_file


