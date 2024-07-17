#/bin/bash
rm -rf memory_usage.txt
output_file="memory_usage.txt"
echo -e "###########################################################\n" >> $output_file
echo -e '\n Memory usage using free command \n' >> $output_file
free -m  >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e ' Processes which are consuming high memory in the server:' >> $output_file
top -o %MEM -b -n 1 | tail -n +4 | head -n 15 >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e ' \n' >> $output_file
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 7 >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e 'Memory usage using top command\n' >> $output_file
top -o %MEM -b -n 1 | head -n 30 >> $output_file
echo -e "###########################################################\n" >> $output_file
echo -e '\n CMD: ps aux --sort=-%mem | head\n' >> $output_file
ps aux --sort=-%mem | head echo -e '\n \n \n CMD: vmstat -s\n' >> $output_file
vmstat -s >> $output_file
