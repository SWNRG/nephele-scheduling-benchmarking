#!/bin/bash
# input:
# cluster_names
# cluster_cpu_utilization
# cluster_memory_utilization
# cluster_node_utilization
# node_cpu_utilization
# node_memory_utilization
# cluster_placement_time
# node_placement_time
# output:
# Creates experiment's output in JSON format.

# cluster_names variable should be specified
if [ -z "${cluster_names}" ]; then
    echo "cluster_names variable should be specified"
    exit 1
fi

# cluster_cpu_utilization variable should be specified
if [ ${#cluster_cpu_utilization[@]} -eq 0 ]; then
    echo "cluster_cpu_utilization variable should be specified"
    exit 1
fi

# cluster_memory_utilization variable should be specified
if [ ${#cluster_memory_utilization[@]} -eq 0 ]; then
    echo "cluster_memory_utilization variable should be specified"
    exit 1
fi

# cluster_node_utilization variable should be specified
if [ ${#cluster_node_utilization[@]} -eq 0 ]; then
    echo "cluster_node_utilization variable should be specified"
    exit 1
fi

# node_cpu_utilization variable should be specified
if [ ${#node_cpu_utilization[@]} -eq 0 ]; then
    echo "node_cpu_utilization variable should be specified"
    exit 1
fi

# node_memory_utilization variable should be specified
if [ ${#node_memory_utilization[@]} -eq 0 ]; then
    echo "node_memory_utilization variable should be specified"
    exit 1
fi

# cluster_placement_time variable should be specified
if [ -z "${cluster_placement_time}" ]; then
    echo "cluster_placement_time variable should be specified"
    exit 1
fi

# node_placement_time variable should be specified
if [ -z "${node_placement_time}" ]; then
    echo "node_placement_time variable should be specified"
    exit 1
fi

# Build cluster array JSON
cluster_json=$(printf '%s\n' "${cluster_names[@]}" | while read -r c; do
  printf '{
    "name": "%s",
    "cpuUtilization": %d,
    "memoryUtilization": %d,
    "nodeUtilization": %d
  },\n' "$c" "${cluster_cpu_utilization[$c]}" "${cluster_memory_utilization[$c]}" "${cluster_node_utilization[$c]}"
done | sed '$ s/,$//') # remove trailing comma

# Build node array JSON
node_json=$(printf '%s\n' "${!node_cpu_utilization[@]}" | while read -r n; do
  printf '{
    "name": "%s",
    "cpuUtilization": %d,
    "memoryUtilization": %d
  },\n' "$n" "${node_cpu_utilization[$n]}" "${node_memory_utilization[$n]}"
done | sed '$ s/,$//') # remove trailing comma

# Final combined JSON
results=$(jq -n \
  --argjson clusterPlacementTime "$cluster_placement_time" \
  --argjson nodePlacementTime "$node_placement_time" \
  --argjson clusters "[$cluster_json]" \
  --argjson nodes "[$node_json]" \
  '{
    placements: {
      clusterPlacementTime: $clusterPlacementTime,
      nodePlacementTime: $nodePlacementTime
    },
    clusters: $clusters,
    nodes: $nodes
  }')

if [[ -v run_id ]]; then
  echo "$results" > results/${experiment_name}/${run_id}-results-${replication}.json
else
  echo "$results" > results.json
fi
echo -e "${GREEN}Results saved to json file${NC}"
