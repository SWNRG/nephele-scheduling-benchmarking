#!/bin/bash

# runs variable should be specified
if [ -z "$runs" ]; then
    echo "runs variable should be specified"
    exit 1
fi

# replications variable should be specified
if [ -z "$replications_number" ]; then
    echo "replications_number variable should be specified"
    exit 1
fi

# experiment_name variable should be specified
if [ -z "$experiment_name" ]; then
    echo "experiment_name variable should be specified"
    exit 1
fi


if [[ -z $metrics ]]; then
   echo "No metrics parameter passed."
   exit 1
else
   if [[ $output_format != "json" ]] && [[ $output_format != "JSON" ]]; then
      echo "Only json output format is supported at this stage."
      exit 1
   fi
fi

# get replication number
replications=$replications_number

# show values from individual runs
show_individual_runs=true

# show average values
show_averages=true

# create separate csv files
create_separate_csv_files=true

increment_char() {
    local char=$1
    local ascii=$(printf "%d" "'$char")
    local incremented_ascii=$((ascii + 1))

    # Handle wrapping from 'z' to 'a'
    if [ "$char" == "z" ]; then
        printf "%s" "a"
    elif [ "$char" == "Z" ]; then
        printf "%s" "A"
    elif [ $incremented_ascii -gt 122 ]; then
        printf "%s" "$(printf \\$(printf '%03o' 97))"
    elif [ $incremented_ascii -gt 90 ] && [ $incremented_ascii -lt 97 ]; then
        printf "%s" "$(printf \\$(printf '%03o' 65))"
    else
        printf "%s" "$(printf \\$(printf '%03o' $incremented_ascii))"
    fi
}

function strip_value () {
  file=$1
  field=$2

  cat $file 2> /dev/null | jq "$field"
}

# validate JSON experiment output (input is the results filename)
validate_json_experiment_output() {
    local json_input=$(cat $1)

    # Check if the experiment output is a valid JSON string
    if ! echo "$json_input" | jq -e . >/dev/null 2>&1; then
        echo ""
    	echo "ERROR: Invalid format for results in $1. It should be a valid JSON string."
	echo ""
	echo "You can remove the file and execute experiment again."
	echo "Check its contents for debug information."
        echo ""
	exit 1
    fi
}

function process_metric() {
  local metric_type=$1

  # Extract the metric details from the JSON
  local states=$(echo "$metrics" | jq -r --arg metric_type "$metric_type" '.[$metric_type].values | join(" ")')
  local columns=$(echo "$metrics" | jq -r --arg metric_type "$metric_type" '.[$metric_type].columns | join(" ")')
  local rows=$(echo "$metrics" | jq -r --arg metric_type "$metric_type" '.[$metric_type].rows')

  echo "states: $states"
  echo "columns: $columns"
  echo "rows: $rows"

  local tmpfile="/tmp/${metric_type}.txt"

  local csvfile="results/${experiment_name}/${metric_type}.csv"

  if $create_separate_csv_files; then
    echo "$rows" > "$csvfile"
    echo "$columns" >> "$csvfile"
  fi

  # Iterate through all runs
  for run in "${runs[@]}"; do
    # Reset temp file
    rm "$tmpfile" 2> /dev/null

    # Loop according to the replication number
    for ((k=1; k<=$replications; k++)); do
      local name=$run

      if $show_individual_runs; then
        echo -n "$name " | tee -a "$tmpfile"
      else
        echo -n "$name " >> "$tmpfile"
      fi

      # declare results filename
      local filename="results/${experiment_name}/${run}-results-$k.json"
      # check if they are valid results
      validate_json_experiment_output $filename

      # Process states
      for state in $states; do
        local current_value=$(strip_value "$filename" "$state")
        [[ -z "$current_value" ]] && current_value=0
        if $show_individual_runs; then
          echo -n "$current_value " | tee -a "$tmpfile"
        else
          echo -n "$current_value " >> "$tmpfile"
        fi
      done

      if $show_individual_runs; then
        echo "" | tee -a "$tmpfile"
      else
        echo "" >> "$tmpfile"
      fi
    done

    # Calculate and display average values
    if $show_averages; then
      
      local num_states=$(($(echo "$states" | wc -w) + 1))

      awk_command="{"
      character='A'
      for ((z=1; z<=$num_states; z++)); do
	 if [[ $z -eq 1 ]]; then
            awk_command="${awk_command}${character}=\$$z;"
	 else
            awk_command="${awk_command}${character}+=\$$z;"
         fi
	 character=$(increment_char $character)
      done
      awk_command="${awk_command}} END { printf \"%s"
      for ((z=2; z<=$num_states; z++)); do
	 awk_command="${awk_command} %.2f"
      done
      awk_command="${awk_command}\n\""
      character='A'
      for ((z=1; z<=$num_states; z++)); do
	 if [[ $z -eq 1 ]]; then
            awk_command="${awk_command},${character}"
         else
            awk_command="${awk_command},${character}/NR"
         fi
         character=$(increment_char $character)
      done
      awk_command="${awk_command}}"

      cat $tmpfile | awk "$awk_command"

      if $create_separate_csv_files; then
        cat $tmpfile | awk "$awk_command" >> "$csvfile"
      fi
    fi
  done
}

# extract and process all metrics defined in metrics variable

metric_names=$(echo "$metrics" | jq -r 'keys[]')
for metric in $metric_names; do
   echo "processing metric $metric"
   process_metric "$metric"
   echo ""
done
