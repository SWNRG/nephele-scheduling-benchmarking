#!/bin/bash

# Define color codes
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m' # No Color

# Define config files
METRICS_CONFIG="metrics-usage.yaml"
ANNOTATED_RESOURCES="annotated-resources.yaml"

# Define clusters' configuration
cluster_names=("cluster1" "cluster2" "cluster3")  # name of clusters
cluster_nodes=(2 2 3) # number of nodes per cluster
cluster_cpu=(32 32 32)  # cpu of cluster nodes
cluster_memory=("256Gi" "256Gi" "256Gi")  # memory of cluster nodes
cluster_pods=(100 100 100)   # maximum number of pods to allocate
cluster_gpus=(0 0 0)

# Define service slices configuration
services_names=("lightmemory" "heavymemory" "lightcpu" "mediumcpu" "secondheavymemory" "heavycpu") # use different names per service!
# if services_placements is specified, it skips multi-cluster placement process
#services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")
services_dependencies=("heavymemory" "" "mediumcpu" "" "heavycpu" "")
services_cpu=("light" "light" "light" "medium" "light" "large")
services_memory=("light" "large" "light" "light" "large" "light")
services_replicas=(1 1 1 1 1 1) # number of times to replicate each service
services_gpus=(0 0 0 0 0 0) # whether each service requires gpu acceleration or not

# Translating intents
echo -e "${GREEN}Translating intents${NC}"
source ./translateIntents.sh

echo ""

# Executing scheduler
echo -e "${GREEN}Executing scheduler${NC}"
source ./executeScheduler.sh

echo ""

# Creating clusters
echo -e "${GREEN}Creating clusters${NC}"
source ./createClusters.sh

create_clusters

# Looking up clusters' nodes
for i in "${!cluster_names[@]}"; do
  cluster_name="${cluster_names[$i]}"

  # Looking up nodes of cluster
  echo "Looking up nodes of $cluster_name"
  kwokctl --name=$cluster_name kubectl get nodes
done

echo ""

# Multi-cluster service placement (choosing cluster per service)
# Should return services_placements array.
echo -e "${GREEN}Creating service JSON${NC}"
source ./createServiceJSON.sh
json=$(create_service_json "")
echo "$json"

# Timing cluster placement
start_cluster_placement=$(date +%s)

# request cluster placement
response=$(curl -X POST "http://127.0.0.1:8000/clusterplacement" \
-H "Content-Type: application/json" \
-d "$json")

if ! echo "$response" | jq . >/dev/null 2>&1; then
  echo -e "${RED}Error: Invalid response from scheduler:${NC}"
  echo "$response"
  exit 1
fi

echo "response is: $response"

end_cluster_placement=$(date +%s)
cluster_placement_time=$((end_cluster_placement - start_cluster_placement))

# Now convert JSON array to bash array
placement_array=($(echo "$response" | jq '.[]'))

# Iterate over placement_array to map service indices to cluster names
services_placements=()

for i in "${!placement_array[@]}"; do
  index=$(( ${placement_array[i]} - 1 ))
  cluster="${cluster_names[$index]}"
  services_placements+=("$cluster")
done

# Print all service placements
echo "${services_placements[@]}"

#services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")

echo ""

# Local cluster service placement (choosing cluster nodes per service)
echo -e "${GREEN}Placing services${NC}"
# Timing node placement
start_node_placement=$(date +%s)
source ./placeServices.sh
end_node_placement=$(date +%s)
node_placement_time=$((end_node_placement - start_node_placement))

# Looking up clusters' pods
for i in "${!cluster_names[@]}"; do
  cluster_name="${cluster_names[$i]}"

  # Looking up pods of cluster
  echo "Looking up pods of $cluster_name"
  kwokctl --name=$cluster_name kubectl get pods -o wide
done

echo ""

# Waiting for experiment to complete
echo -e "${GREEN}Waiting for experiment to complete${NC}"
sleep 60

echo ""

# Looking up cluster resources
echo -e "${GREEN}Looking up cluster resources${NC}"
source ./clusterResources.sh

echo ""


# Metrics gathering
echo -e "${GREEN}Gathering resource metrics (CPU & Memory)${NC}"

declare -A cluster_cpu_utilization
declare -A cluster_node_utilization
declare -A cluster_memory_utilization
declare -A node_cpu_utilization
declare -A node_utilization
declare -A node_memory_utilization

for i in "${!cluster_names[@]}"; do
  cluster="${cluster_names[$i]}"
  nodes=${cluster_nodes[$i]}
  echo -e "${YELLOW}Fetching metrics for $cluster${NC}"

  node_metrics=$(kwokctl --name=$cluster kubectl top nodes --no-headers 2>/dev/null)

  total_cpu=0
  total_mem=0
  total_cpu_capacity=$((cluster_cpu[$i] * 1000 * nodes))  # assuming 'm' (millicores)
  total_mem_capacity=$(echo "${cluster_memory[$i]}" | sed 's/Gi//' | awk "{ print $1 * 1024 * 1024 }")
  total_mem_capacity=$((total_mem_capacity * nodes))  # in Ki

  used_nodes=0

  while read -r line; do
    node_name=$(echo "$line" | awk '{print $1}')
    cpu_usage=$(echo "$line" | awk '{print $2}' | sed 's/m//')
    mem_usage_raw=$(echo "$line" | awk '{print $3}')
    
    # Normalize memory to Ki
    if [[ $mem_usage_raw == *Ki ]]; then
      mem_usage=$(echo "$mem_usage_raw" | sed 's/Ki//')
    elif [[ $mem_usage_raw == *Mi ]]; then
      mem_usage=$(echo "$mem_usage_raw" | sed 's/Mi//')
      mem_usage=$((mem_usage * 1024))
    elif [[ $mem_usage_raw == *Gi ]]; then
      mem_usage=$(echo "$mem_usage_raw" | sed 's/Gi//')
      mem_usage=$((mem_usage * 1024 * 1024))
    fi

    # Calculate usage %
    cpu_percent=$((cpu_usage * 100 / (cluster_cpu[$i] * 1000)))
    mem_percent=$((mem_usage * 100 / ( $(echo "${cluster_memory[$i]}" | sed 's/Gi//') * 1024 * 1024 )))

    node_cpu_utilization["$node_name"]=$cpu_percent
    node_memory_utilization["$node_name"]=$mem_percent
    node_utilization["$node_name"]=100

    total_cpu=$((total_cpu + cpu_usage))
    total_mem=$((total_mem + mem_usage))
    used_nodes=$((used_nodes + 1))
  done <<< "$node_metrics"

  cluster_cpu_utilization["$cluster"]=$((total_cpu * 100 / total_cpu_capacity))
  cluster_memory_utilization["$cluster"]=$((total_mem * 100 / total_mem_capacity))
  cluster_node_utilization["$cluster"]=$((used_nodes * 100 / nodes))
done

echo ""

# Generating results.json
echo -e "${GREEN}Generating results.json${NC}"

results=$(jq -n \
  --argjson clusterPlacementTime "$cluster_placement_time" \
  --argjson nodePlacementTime "$node_placement_time" \
  --argjson clusters "$(jq -n '[
    '"$(for c in "${cluster_names[@]}"; do
      printf '{
        "name": "%s",
        "cpuUtilization": %d,
        "memoryUtilization": %d,
        "nodeUtilization": %d
      },' "$c" "${cluster_cpu_utilization[$c]}" "${cluster_memory_utilization[$c]}" "${cluster_node_utilization[$c]}"
    done | sed 's/,$//')'
  ]')" \
  --argjson nodes "$(jq -n '[
    '"$(for n in "${!node_cpu_utilization[@]}"; do
      printf '{
        "name": "%s",
        "cpuUtilization": %d,
        "memoryUtilization": %d,
        "nodeUtilization": %d
      },' "$n" "${node_cpu_utilization[$n]}" "${node_memory_utilization[$n]}" "${node_utilization[$n]}"
    done | sed 's/,$//')'
  ]')" \
  '{
    clusterPlacementTime: $clusterPlacementTime,
    nodePlacementTime: $nodePlacementTime,
    clusters: $clusters,
    nodes: $nodes
  }'
)

echo "$results" > results.json
echo -e "${GREEN}Results saved to results.json${NC}"

echo ""

# Removing clusters
echo -e "${GREEN}Removing clusters${NC}"
source ./removeClusters.sh

echo ""

