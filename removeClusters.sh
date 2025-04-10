#!/bin/bash
# input:
# cluster_names
# output:
# deletes all clusters specified in 
# cluster_names.

# cluster_names variable should be specified
if [ -z "$cluster_names" ]; then
    echo "cluster_names variable should be specified"
    exit 1
fi

# Remove existing clusters
for i in "${!cluster_names[@]}"; do
  cluster_name="${cluster_names[$i]}"

  echo "Deleting $cluster_name"
  kwokctl delete cluster --name=$cluster_name
done
