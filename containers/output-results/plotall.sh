#!/bin/bash

metrics_file="/root/results/metrics"

echo "Creating latex file"
cat results-template.tex > results.tex
echo "\\section{Plotting all figures}" >> results.tex

# iterate through all metrics
# Read each line of the file
while IFS= read -r line; do

    # Split the line into individual fields based on space as the delimiter
    fields=($line)
    
    # Access specific fields
    # Get metric name
    metric_name="${fields[0]}"
    # Get metric data file
    metric_data="${fields[1]}"
    # Get metric title (extract using awk, so double quote is not confusing)
    metric_title=$(awk -F '"' '{print $2}' <<< "$line")

    echo "Processing metric: $metric_name  metric_title: $metric_title"

    # Create a new line from all fields besides the first one
    plotlines_input="${fields[@]:1}"

    # Generating plot.p file, try to handle parameters with spaces
    IFS='|' read -r -a input_array <<< "$plotlines_input"
    # Prepare the command with proper quoting
    cmd="/root/plotlines.sh"
    for arg in "${input_array[@]}"; do
        cmd+=" $arg"
    done
    # Execute the command
    eval "$cmd"

    # Generate figures
    echo "generating figure"
    gnuplot plot.p > /root/results/${metric_name}.eps
    # Keep plot file
    cp plot.p /root/results/${metric_name}.p

    #echo "generating pdf files"

    # creating subsection for particular metric in latex file
    echo "\\subsection{${metric[$count]}}" >> results.tex
    /root/addlatexfigures "${metric_name}.eps" "$metric_title" "$metric_data"
done < "$metrics_file"

echo "" >> results.tex
echo "\\end{document}" >> results.tex

echo "Creating Latex file"

/root/createoutputpdf

# move results.pdf to results folder
mv /root/results.pdf /root/results/

# move results.tex to results folder
mv /root/results.tex /root/results/

# delete temporary files
rm /root/results/*.t 2> /dev/null
#rm /root/results/*.o 2> /dev/null
rm /root/results/*.s 2> /dev/null
