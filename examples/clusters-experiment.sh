#!/bin/bash

# specify run ids (check reconfigureExperiment.sh)
runs=("clusters-3" "clusters-5" "clusters-10")

# number of replications
replications_number=1

# name of experiment
experiment_name="range-clusters"

# wait time between experiments
experiment_wait_time=60

# structure of experiment output
metrics='{
  "placement-times": {
    "values": [
      ".placements.clusterPlacementTime",
      ".placements.nodePlacementTime"
    ],
    "columns": [
      "clusters",
      "cluster-placement-time",
      "node-placement-time"
    ],
    "rows": "Cluster and Node Placement Times (ms)"
  },
  "cluster-cpu-utilization": {
    "values": [
      ".clusters[0].cpuUtilization",
      ".clusters[1].cpuUtilization",
      ".clusters[2].cpuUtilization",
      ".clusters[3].cpuUtilization",
      ".clusters[4].cpuUtilization",
      ".clusters[5].cpuUtilization",
      ".clusters[6].cpuUtilization",
      ".clusters[7].cpuUtilization",
      ".clusters[8].cpuUtilization",
      ".clusters[9].cpuUtilization"
    ],
    "columns": [
      "clusters",
      "cluster-1",
      "cluster-2",
      "cluster-3",
      "cluster-4",
      "cluster-5",
      "cluster-6",
      "cluster-7",
      "cluster-8",
      "cluster-9",
      "cluster-10"
    ],
    "rows": "Cluster CPU Utilization (%)"
  },
  "cluster-memory-utilization": {
    "values": [
      ".clusters[0].memoryUtilization",
      ".clusters[1].memoryUtilization",
      ".clusters[2].memoryUtilization",
      ".clusters[3].memoryUtilization",
      ".clusters[4].memoryUtilization",
      ".clusters[5].memoryUtilization",
      ".clusters[6].memoryUtilization",
      ".clusters[7].memoryUtilization",
      ".clusters[8].memoryUtilization",
      ".clusters[9].memoryUtilization"
    ],
    "columns": [
      "clusters",
      "cluster-1",
      "cluster-2",
      "cluster-3",
      "cluster-4",
      "cluster-5",
      "cluster-6",
      "cluster-7",
      "cluster-8",
      "cluster-9",
      "cluster-10"
    ],
    "rows": "Cluster Memory Utilization (%)"
  },
  "cluster-node-utilization": {
    "values": [
      ".clusters[0].nodeUtilization",
      ".clusters[1].nodeUtilization",
      ".clusters[2].nodeUtilization",
      ".clusters[3].nodeUtilization",
      ".clusters[4].nodeUtilization",
      ".clusters[5].nodeUtilization",
      ".clusters[6].nodeUtilization",
      ".clusters[7].nodeUtilization",
      ".clusters[8].nodeUtilization",
      ".clusters[9].nodeUtilization"
    ],
    "columns": [
      "clusters",
      "cluster-1",
      "cluster-2",
      "cluster-3",
      "cluster-4",
      "cluster-5",
      "cluster-6",
      "cluster-7",
      "cluster-8",
      "cluster-9",
      "cluster-10"
    ],
    "rows": "Cluster Node Utilization (%)"
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
    }
]'

# go to main folder
cd ..

# create results folder, if it does not exist
mkdir results/${experiment_name} 2> /dev/null

for run_id in "${runs[@]}"; do
  echo "Executing run_id: $run_id"

  # loop according to the replication number
  for ((replication=1; replication<=$replications_number; replication++))
  do
    echo "Executing replication: $replication"
    source ./mcs-experiments.sh
    echo "Waiting a bit between experiments"
    sleep $experiment_wait_time
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
