#!/bin/bash

# specify run ids (check reconfigureExperiment.sh)
runs=("clusters-3" "clusters-5" "clusters-10")

# number of replications
replications_number=10

# name of experiment
experiment_name="range-clusters"

# wait time between experiments
experiment_wait_time=60

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
      "clusters",
      "cluster-placement-time",
      "node-placement-time"
    ],
    "rows": "Cluster and Node Placement Times (s)"
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
      ".nodes[8].cpuUtilization",
      ".nodes[9].cpuUtilization",
      ".nodes[10].cpuUtilization",
      ".nodes[11].cpuUtilization",
      ".nodes[12].cpuUtilization",
      ".nodes[13].cpuUtilization",
      ".nodes[14].cpuUtilization",
      ".nodes[15].cpuUtilization",
      ".nodes[16].cpuUtilization",
      ".nodes[17].cpuUtilization",
      ".nodes[18].cpuUtilization",
      ".nodes[19].cpuUtilization"
    ],
    "columns": [
      "nodes",
      "cluster-1-node1",
      "cluster-1-node2",
      "cluster-2-node1",
      "cluster-2-node2",
      "cluster-3-node1",
      "cluster-3-node2",
      "cluster-4-node1",
      "cluster-4-node2",
      "cluster-5-node1",
      "cluster-5-node2",
      "cluster-6-node1",
      "cluster-6-node2",
      "cluster-7-node1",
      "cluster-7-node2",
      "cluster-8-node1",
      "cluster-8-node2",
      "cluster-9-node1",
      "cluster-9-node2",
      "cluster-10-node1",
      "cluster-10-node2"
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
      ".nodes[8].memoryUtilization",
      ".nodes[9].memoryUtilization",
      ".nodes[10].memoryUtilization",
      ".nodes[11].memoryUtilization",
      ".nodes[12].memoryUtilization",
      ".nodes[13].memoryUtilization",
      ".nodes[14].memoryUtilization",
      ".nodes[15].memoryUtilization",
      ".nodes[16].memoryUtilization",
      ".nodes[17].memoryUtilization",
      ".nodes[18].memoryUtilization",
      ".nodes[19].memoryUtilization"
    ],
    "columns": [
      "nodes",
      "cluster-1-node1",
      "cluster-1-node2",
      "cluster-2-node1",
      "cluster-2-node2",
      "cluster-3-node1",
      "cluster-3-node2",
      "cluster-4-node1",
      "cluster-4-node2",
      "cluster-5-node1",
      "cluster-5-node2",
      "cluster-6-node1",
      "cluster-6-node2",
      "cluster-7-node1",
      "cluster-7-node2",
      "cluster-8-node1",
      "cluster-8-node2",
      "cluster-9-node1",
      "cluster-9-node2",
      "cluster-10-node1",
      "cluster-10-node2"
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
        "transpose": "no",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Service Replicas Number",
	"ylabel": "Time (s)",
        "xrange": "auto",
        "yrange": "auto",
        "boxvertical": "top",
        "boxhorizontal": "left",
        "boxlegend": "cluster-placement-time 2 node-placement-time 3",
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
        "xlabel": "Node",
        "ylabel": "CPU (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "0.58",
        "boxhorizontal": "0.98",
        "xticksrotate": "0 scale 0"
    },
    {
        "name": "node-memory-utilization",
        "filename": "node-memory-utilization.csv",
        "title": "Node Memory Utilization",
        "striptitle": "yes",
        "transpose": "yes",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Node",
        "ylabel": "Memory (%)",
        "xrange": "auto",
        "yrange": "[0:100]",
        "boxvertical": "top",
        "boxhorizontal": "right",
        "xticksrotate": "0 scale 0"
    }
]'

# go to main folder
cd ..

# executing experiment-controller to handle the rest of experiment
source ./experiment-controller.sh
