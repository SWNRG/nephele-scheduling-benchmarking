#!/bin/bash

# create metrics substring
counter=2  # Start counter at 2
substring=""
for run in "${runs[@]}";
do
   # create metrics substring
   if [[ -z $substring ]]; then
     substring="$run $counter"
   else
     substring="$substring $run $counter"
   fi
   ((counter++))  # Increment the counter
done

# remove metrics file, if it exists
rm results/${experiment_name}/metrics 2> /dev/null

# Read JSON file and iterate through each object
echo $graphs | jq -c '.[]' | while IFS= read -r obj; do
    # Extract parameters from each object
    name=$(echo "$obj" | jq -r '.name')
    filename=$(echo "$obj" | jq -r '.filename')
    title=$(echo "$obj" | jq -r '.title')
    striptitle=$(echo "$obj" | jq -r '.striptitle')
    transpose=$(echo "$obj" | jq -r '.transpose')
    filterkeyword=$(echo "$obj" | jq -r '.filterkeyword')
    removekeyword=$(echo "$obj" | jq -r '.removekeyword')
    xlabel=$(echo "$obj" | jq -r '.xlabel')
    ylabel=$(echo "$obj" | jq -r '.ylabel')
    xrange=$(echo "$obj" | jq -r '.xrange')
    yrange=$(echo "$obj" | jq -r '.yrange')
    boxvertical=$(echo "$obj" | jq -r '.boxvertical')
    boxhorizontal=$(echo "$obj" | jq -r '.boxhorizontal')
    boxlegend=$(echo "$obj" | jq -r '.boxlegend // ""')
    xticksrotate=$(echo "$obj" | jq -r '.xticksrotate')

    if [[ -z "$boxlegend" ]]; then
      # substring (legend details) is not directly passed
      boxlegend=$substring
    fi
    # create metrics file based on all parameters
    echo "$name $filename \"$title\" $striptitle $transpose $filterkeyword $removekeyword \"$xlabel\" \"$ylabel\" $xrange $yrange $boxvertical $boxhorizontal \"$xticksrotate\" $boxlegend" >> results/${experiment_name}/metrics
done


# example output
#cat <<EOF > results/metrics
#plugins-net net.csv "Internal Throughput of Network Plugins" yes yes no no "Communication Type" "Throughput(Mbps)" auto [0:5000] top right "-45 scale 0" $substring
#plugins-cpu-client cpu.csv "CPU Utilization of Network Plugins (Client)" yes yes server "-client" "Communication Type" "CPU(%)" auto [0:40] top left "-45 scale 0" $substring
#plugins-mem-client mem.csv "RAM Consumption of Network Plugins (Client)" yes yes server "-client" "Communication Type" "RAM(MB)" auto [0:900] bottom right "-45 scale 0" $substring
#plugins-cpu-server cpu.csv "CPU Utilization of Network Plugins (Server)" yes yes client "-server" "Communication Type" "CPU(%)" auto [0:40] top left "-45 scale 0" $substring
#plugins-mem-server mem.csv "RAM Consumption of Network Plugins (Server)" yes yes client "-server" "Communication Type" "RAM(MB)" auto [0:900] bottom right "-45 scale 0" $substring
#EOF
