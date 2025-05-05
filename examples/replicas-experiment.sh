#!/bin/bash

# specify run ids (check reconfigureExperiment.sh)
runs=("replica-1" "replicas-5" "replicas-10" "replicas-20" "replicas-30")

# number of replications
replications_number=1

# name of experiment
experiment_name="service-replicas"

# wait time between experiments
experiment_wait_time=120

# structure of experiment output
metrics='{
  "placement-times": {
    "values": [
      ".placements.clusterPlacementTime",
      ".placements.nodePlacementTime"
    ],
    "columns": [
      "replications",
      "cluster-placement-time",
      "node-placement-time"
    ],
    "rows": "Cluster and Node Placement Times (ms)"
  },
  "cluster-cpu-utilization": {
    "values": [
      ".clusters[0].cpuUtilization",
      ".clusters[1].cpuUtilization",
      ".clusters[2].cpuUtilization"
    ],
    "columns": [
      "replications",
      "cluster-1",
      "cluster-2",
      "cluster-3"
    ],
    "rows": "Cluster CPU Utilization (%)"
  },
  "cluster-memory-utilization": {
    "values": [
      ".clusters[0].memoryUtilization",
      ".clusters[1].memoryUtilization",
      ".clusters[2].memoryUtilization"
    ],
    "columns": [
      "replications",
      "cluster-1",
      "cluster-2",
      "cluster-3"
    ],
    "rows": "Cluster Memory Utilization (%)"
  },
  "cluster-node-utilization": {
    "values": [
      ".clusters[0].nodeUtilization",
      ".clusters[1].nodeUtilization",
      ".clusters[2].nodeUtilization"
    ],
    "columns": [
      "replications",
      "cluster-1",
      "cluster-2",
      "cluster-3"
    ],
    "rows": "Cluster Node Utilization (%)"
  },
  "node-cpu-utilization": {
    "values": [
      ".nodes[0].cpuUtilization",
      ".nodes[1].cpuUtilization",
      ".nodes[2].cpuUtilization",
      ".nodes[3].cpuUtilization",
      ".nodes[4].cpuUtilization",
      ".nodes[5].cpuUtilization"
    ],
    "columns": [
      "nodes",
      "cluster-1-node1",
      "cluster-1-node2",
      "cluster-2-node1",
      "cluster-2-node2",
      "cluster-3-node1",
      "cluster-3-node2"
    ],
    "rows": "Node CPU Utilization (%)"
  },
  "node-memory-utilization": {
    "values": [
      ".nodes[0].memoryUtilization",
      ".nodes[1].memoryUtilization",
      ".nodes[2].memoryUtilization",
      ".nodes[3].memoryUtilization",
      ".nodes[4].memoryUtilization",
      ".nodes[5].memoryUtilization"
    ],
    "columns": [
      "nodes",
      "cluster-1-node1",
      "cluster-1-node2",
      "cluster-2-node1",
      "cluster-2-node2",
      "cluster-3-node1",
      "cluster-3-node2"
    ],
    "rows": "Node Memory Utilization (%)"
  }
}'

graphs='[
    {
        "name": "placement-times",
        "filename": "placement-times.csv",
        "title": "Cluster and Node Placement Times",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Service Replicas Number",
	"ylabel": "Time (ms)",
        "xrange": "auto",
        "yrange": "auto",
        "boxvertical": "top",
        "boxhorizontal": "left",
        "xticksrotate": "-45 scale 0"
    },
    {
        "name": "cluster-cpu-utilization",
        "filename": "cluster-cpu-utilization.csv",
        "title": "Cluster CPU Utilization",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Cluster",
        "ylabel": "CPU (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "top",
        "boxhorizontal": "right",
        "xticksrotate": "-45 scale 0"
    },
    {
        "name": "cluster-memory-utilization",
        "filename": "cluster-memory-utilization.csv",
        "title": "Cluster Memory Utilization",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Cluster",
        "ylabel": "Memory (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "top",
        "boxhorizontal": "right",
        "xticksrotate": "-45 scale 0"
    },
    {
        "name": "cluster-node-utilization",
        "filename": "cluster-node-utilization.csv",
        "title": "Cluster Node Utilization",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Cluster",
        "ylabel": "Node (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "top",
        "boxhorizontal": "right",
        "xticksrotate": "-45 scale 0"
    },
    {
        "name": "node-cpu-utilization",
        "filename": "node-cpu-utilization.csv",
        "title": "Node CPU Utilization",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Cluster",
        "ylabel": "CPU (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "top",
        "boxhorizontal": "right",
        "xticksrotate": "-45 scale 0"
    },
    {
        "name": "node-memory-utilization",
        "filename": "node-memory-utilization.csv",
        "title": "Node Memory Utilization",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Cluster",
        "ylabel": "Memory (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "top",
        "boxhorizontal": "right",
        "xticksrotate": "-45 scale 0"
    }
]'

# go to main folder
cd ..

# create results folder, if it does not exist
mkdir results/${experiment_name} 2> /dev/null

for j in "${!runs[@]}"; do
  run_id="${runs[$j]}"
  echo "Executing run_id: $run_id"

  # loop according to the replication number
  for ((replication=1; replication<=$replications_number; replication++))
  do
    echo "Executing replication: $replication"
    source ./mcs-experiments.sh

    # Only sleep if it's not the last replication of the last run
    if ! [[ "$j" == "$((${#runs[@]} - 1))" && $replication == $replications_number || $dry_run == "true" ]]; then
      echo "Waiting a bit between experiments"
      sleep $experiment_wait_time
      echo ""
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
