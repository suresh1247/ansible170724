#!/bin/bash
>output_logs.txt
>count.txt
# Input file containing keywords
keywords_file="keywords.txt"
# Output file to store results
output_file="log_analysis_"

# Array to store unique lines
declare -A unique_lines
grep -v -f exclude_keywords.txt /var/log/* >> output_logs.txt

# Function to fetch 10 lines before and after keyword occurrence
while IFS= read -r keyword; do

    # Search for keyword occurrences and fetch context
    grep -n -A 10 -B 10 "$keyword" output_logs.txt | \
    while IFS= read -r line; do
        # Check if line already exists in output file
        if [[ -z "${unique_lines[$line]}" ]]; then
            echo "$line" >> "$output_file$keyword.txt"
            unique_lines["$line"]=1
        fi
    done
    count=$(grep "$keyword" /home/suresh/log_analysis_* | wc -l)
    echo " $keyword : $count " >> count.txt
done < "$keywords_file"
