#!/bin/bash

# create results folder, if it does not exist
mkdir results/${experiment_name} 2> /dev/null

for j in "${!runs[@]}"; do
  run_id="${runs[$j]}"
  echo "Executing run_id: $run_id"

  # loop according to the replication number
  for ((replication=1; replication<=$replications_number; replication++))
  do
    filename="results/${experiment_name}/${run_id}-results-${replication}.json"
    # execute if output file does not exist
    if [[ ! -f $filename ]]; then
      echo "Executing replication: $replication"
      source ./mcs-experiments.sh

      # Only sleep if it's not the last replication of the last run
      if ! [[ "$j" == "$((${#runs[@]} - 1))" && $replication == $replications_number || $dry_run == "true" ]]; then
        echo "Waiting a bit between experiments"
        sleep $experiment_wait_time
        echo ""
      fi
    else
      echo "Results already exist for output $filename."
    fi
  done
done

# Preparing results
echo "Preparing results"
source ./getResults.sh

echo ""

# Generating graphs
echo "Generating graphs"
# create appropriate metrics file
if [[ -z $graphs ]]; then
   echo "No graphs parameter passed, skipping creating metrics and output pdf stages."
else
   echo ""
   echo "Creating appropriate metrics file"
   echo ""
   source ./createMetricsFile.sh

   # create output PDF
   echo ""
   echo "Creating output PDF file"
   echo ""
   source ./outputResultsContainer.sh
fi

echo ""
