#!/bin/bash

# specify run ids (check reconfigureExperiment.sh)
runs=("light-memory" "medium-memory" "large-memory" "mixture-memory")

# number of replications
replications_number=1

# name of experiment
experiment_name="heterogeneous-clusters-memory-apps"

# wait time between experiments
experiment_wait_time=120

# service placement period (in secs)
placement_period=120

# format of experiment output (e.g., json)
output_format='json'

# structure of experiment output
metrics='{
  "placement-times": {
    "values": [
      ".placements.clusterPlacementTime",
      ".placements.nodePlacementTime"
    ],
    "columns": [
      "services",
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
      "clusters",
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
      "clusters",
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
      "clusters",
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
      ".nodes[5].cpuUtilization",
      ".nodes[6].cpuUtilization",
      ".nodes[7].cpuUtilization",
      ".nodes[8].cpuUtilization"
    ],
    "columns": [
      "nodes",
      "cluster-1-node1",
      "cluster-1-node2",
      "cluster-2-node1",
      "cluster-2-node2",
      "cluster-2-node3",
      "cluster-3-node1",
      "cluster-3-node2",
      "cluster-3-node3",
      "cluster-3-node4"
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
      ".nodes[5].memoryUtilization",
      ".nodes[6].memoryUtilization",
      ".nodes[7].memoryUtilization",
      ".nodes[8].memoryUtilization"
    ],
    "columns": [
     "nodes",
      "cluster-1-node1",
      "cluster-1-node2",
      "cluster-2-node1",
      "cluster-2-node2",
      "cluster-2-node3",
      "cluster-3-node1",
      "cluster-3-node2",
      "cluster-3-node3",
      "cluster-3-node4"
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

# executing experiment-controller to handle the rest of experiment
source ./experiment-controller.sh
