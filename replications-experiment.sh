#!/bin/bash

# specify run ids (check case statement in mcs-experiments.sh)
runs=("replica-1" "replicas-5" "replicas-10")

# number of replications
replications_number=1

# name of experiment
experiment_name="service-replicas"

for run_id in "${runs[@]}"; do
  echo "Executing run_id: $run_id"

  # loop according to the replication number
  for ((replication=1; replication<=$replications_number; replication++))
  do
    echo "Executing replication: $replication"
    source ./mcs-experiments.sh
  done
done

# Preparing results
echo "Preparing results"
source ./getResults.sh

echo ""

