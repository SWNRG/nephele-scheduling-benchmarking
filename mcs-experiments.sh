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
cluster_nodes=(2 2 2) # number of nodes per cluster
cluster_cpu=(32 32 32)  # cpu of cluster nodes
cluster_memory=("256Gi" "256Gi" "256Gi")  # memory of cluster nodes
cluster_pods=(100 100 100)   # maximum number of pods to allocate
cluster_gpus=(0 0 0)

# Define service slices configuration (each set is being deployed with a period defined in placement_period variable)
services_names_sets=("lightmemory" "heavymemory" "lightcpu" "mediumcpu" "secondheavymemory" "heavycpu") # use different names per service!
# if services_placements is specified, it skips multi-cluster placement process
#services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")
services_dependencies_sets=("heavymemory" "" "mediumcpu" "" "heavycpu" "")
services_cpu_sets=("light" "light" "light" "medium" "light" "large")
services_memory_sets=("light" "large" "light" "light" "large" "light")
services_replicas_sets=(5 5 5 5 5 5) # number of times to replicate each service
services_gpus_sets=(0 0 0 0 0 0) # whether each service requires gpu acceleration or not

# service placement period (in secs)
placement_period=60

# Executing scheduler
echo -e "${GREEN}Executing scheduler${NC}"
source ./executeScheduler.sh
# wait 5 secs
sleep 5

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

# Iterating through service placements
echo -e "${GREEN}Iterating through service placements${NC}"
for index in "${!services_names_sets[@]}"; do
  services_names=(${services_names_sets[$index]})  # get service set
  if [ -z ${services_dependencies_sets[$index]} ]; then
    services_dependencies=("")
  else
    services_dependencies=(${services_dependencies_sets[$index]})
  fi
  services_cpu=(${services_cpu_sets[$index]})
  services_memory=(${services_memory_sets[$index]})
  services_replicas=(${services_replicas_sets[$index]})
  services_gpus=(${services_gpus_sets[$index]})

  echo -e "${BLUE}Deploying services: ${services_names[@]}${NC}"
  echo "services_dependencies: ${services_dependencies[@]}"
  echo "services_cpu: ${services_cpu[@]}"
  echo "services_memory: ${services_memory[@]}"
  echo "services_replicas: ${services_replicas[@]}"
  echo "services_gpus: ${services_gpus[@]}"

  echo ""

  # Translating intents
  echo -e "${GREEN}Translating intents${NC}"
  source ./translateIntents.sh

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
  source ./clusterPlacement.sh

  end_cluster_placement=$(date +%s)
  cluster_placement_time=$((end_cluster_placement - start_cluster_placement))

  # Now convert JSON array to bash array
  placement_array=($(echo "$response" | jq '.[]'))

  # Iterate over placement_array to map service indices to cluster names
  services_placements=()

  for i in "${!placement_array[@]}"; do
    index=${placement_array[$i]}
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

  # Waiting for deployment to complete
  echo -e "${GREEN}Waiting for experiment to complete${NC}"
  sleep $placement_period

  echo ""
done

# Looking up cluster resources
echo -e "${GREEN}Looking up cluster resources${NC}"
source ./clusterResources.sh

echo ""


# Metrics gathering
echo -e "${GREEN}Gathering resource metrics (CPU & Memory)${NC}"
source ./gatherMetrics.sh

echo ""

# Generating results.json
echo -e "${GREEN}Generating results.json${NC}"
source ./generateOutputJSON.sh

echo ""

# Removing clusters
echo -e "${GREEN}Removing clusters${NC}"
source ./removeClusters.sh

echo ""

