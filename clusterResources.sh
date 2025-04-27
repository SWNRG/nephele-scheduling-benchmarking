#!/bin/bash
# input:
# cluster_names
# output:
# looks up clusters' nodes resource consumption via metrics server

# cluster_names variable should be specified
if [ -z "$cluster_names" ]; then
    echo "cluster_names variable should be specified"
    exit 1
fi

# Looking up clusters' node resources
for i in "${!cluster_names[@]}"; do
  cluster_name="${cluster_names[$i]}"

  # Looking up node resources of cluster
  echo "Looking up node resources of $cluster_name"
  kwokctl --name=$cluster_name kubectl top nodes 2> /dev/null
done
