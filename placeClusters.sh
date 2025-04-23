#!/bin/bash
# input:
# services_names
# services_placements
# services_dependencies
# services_cpu
# services_memory
# services_replicas
# cluster_names
# output:
# Creates service slices in JSON
# and communicates them to scheduler.
# The latter returns cluster nodes to place each slice.
# It then creates appropriate Pods and deploys them
# accordingly.

# services_names variable should be specified
if [ -z "$services_names" ]; then
    echo "services_names variable should be specified"
    exit 1
fi

# services_placement variable should be specified
if [ -z "$services_placements" ]; then
    echo "services_placements variable should be specified"
    exit 1
fi

# services_dependencies variable should be specified
if [ -z "$services_dependencies" ]; then
    echo "services_dependencies variable should be specified"
    exit 1
fi

# services_cpu variable should be specified
if [ -z "$services_cpu" ]; then
    echo "services_cpu variable should be specified"
    exit 1
fi

# services_memory variable should be specified
if [ -z "$services_memory" ]; then
    echo "services_memory variable should be specified"
    exit 1
fi

# services_replicas variable should be specified
if [ -z "$services_replicas" ]; then
    echo "services_replicas variable should be specified"
    exit 1
fi

# cluster_names variable should be specified
if [ -z "$cluster_names" ]; then
    echo "cluster_names variable should be specified"
    exit 1
fi

# Create and place services json
# Use associative array to filter unique values
declare -A seen
# Keep track of placements with placements array
placements=()
for cluster_name in "${cluster_names[@]}"; do
  if [[ -n "${seen[$cluster_name]}" ]]; then
    continue
  fi

  seen[$cluster_name]=1
  echo "Placing services for cluster $cluster_name"

  source ./createServiceJSON.sh

  json=$(create_service_json "$cluster_name")
  echo "$json"

  # communicating service json to scheduler
  placement_result=$(curl -X POST "http://127.0.0.1:8000/nodeplacement?context=$cluster_name" \
-H "Content-Type: application/json" \
-d "$json")
  echo $placement_result

  # keep track of all service placements
  keys=$(echo "$placement_result" | jq -r 'keys[]')

  # Iterate through the keys
  for key in $keys; do
    # extract placement for particular key value
    node_name=$(echo "$placement_result" | jq -r .$key.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0])
    placements+=($node_name)
  done

  echo ""
done

# Creating service pods
echo -e "${GREEN}Creating service pods${NC}"

source ./createServicePods.sh

create_service_pods

