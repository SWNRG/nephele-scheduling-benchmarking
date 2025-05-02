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
services_names_sets=("lightmemory heavymemory lightcpu mediumcpu secondheavymemory heavycpu") # use different names per service!
# if services_placements is specified, it skips multi-cluster placement process
#services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")
services_dependencies_sets=("heavymemory heavymemory mediumcpu heavycpu heavycpu heavycpu")
services_cpu_sets=("light light light medium light large")
services_memory_sets=("light large light light large light")
services_replicas_sets=("10 10 10 10 10 10") # number of times to replicate each service
services_gpus_sets=("0 0 0 0 0 0") # whether each service requires gpu acceleration or not

# service placement period (in secs)
placement_period=60

# format of experiment output (e.g., json)
output_format='json'

# dry run option
dry_run=false #true

# Reconfigure experiment based on run_id, if it is specified

# Reconfigure experiment, if run_id has been specified
if [[ -v run_id ]]; then
  source ./reconfigureExperiment.sh
fi

# Executing scheduler
echo -e "${GREEN}Executing scheduler${NC}"
if [ "$dry_run" != "true" ]; then
  source ./executeScheduler.sh
  # wait 5 secs
  sleep 5
fi
echo ""

# Creating clusters
echo -e "${GREEN}Creating clusters${NC}"
if [ "$dry_run" != "true" ]; then
  source ./createClusters.sh
  create_clusters
fi

# Looking up clusters' nodes
for i in "${!cluster_names[@]}"; do
  cluster_name="${cluster_names[$i]}"

  # Looking up nodes of cluster
  echo "Looking up nodes of $cluster_name"
  if [ "$dry_run" != "true" ]; then
    kwokctl --name=$cluster_name kubectl get nodes
  fi
done

echo ""

# Iterating through service placements
echo -e "${GREEN}Iterating through service placements${NC}"
# Keep track of all cluster placement times
cluster_placement_times=()
# Keep track of all node placement times
node_placement_times=()

for index in "${!services_names_sets[@]}"; do
  services_names=(${services_names_sets[$index]})  # get service set
  if [ -z "${services_dependencies_sets[$index]}" ]; then
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
  if [ "$dry_run" != "true" ]; then
    source ./clusterPlacement.sh
  fi
  end_cluster_placement=$(date +%s)
  cluster_placement_times+=($((end_cluster_placement - start_cluster_placement)))

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

  #echo "Changing service placements to:"
  #services_placements=(cluster1 cluster2 cluster3)
  #echo "${services_placements[@]}"
  #services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")
  echo ""

  # Local cluster service placement (choosing cluster nodes per service)
  echo -e "${GREEN}Placing services${NC}"
  # Timing node placement
  start_node_placement=$(date +%s)
  if [ "$dry_run" != "true" ]; then
    source ./placeServices.sh
  fi
  end_node_placement=$(date +%s)
  node_placement_times+=($((end_node_placement - start_node_placement)))

  # Looking up clusters' pods
  for i in "${!cluster_names[@]}"; do
    cluster_name="${cluster_names[$i]}"

    # Looking up pods of cluster
    echo "Looking up pods of $cluster_name"
    if [ "$dry_run" != "true" ]; then
      kwokctl --name=$cluster_name kubectl get pods -o wide
    fi
  done

  echo ""

  # Waiting for deployment to complete
  echo -e "${GREEN}Waiting for experiment to complete${NC}"
  if [ "$dry_run" != "true" ]; then
    sleep $placement_period
  fi
  echo ""
done

# Looking up cluster resources
echo -e "${GREEN}Looking up cluster resources${NC}"
source ./clusterResources.sh

echo ""


# Metrics gathering
echo -e "${GREEN}Gathering resource metrics (CPU & Memory)${NC}"
if [ "$dry_run" != "true" ]; then
  source ./gatherMetrics.sh
fi
echo ""

# Generating results.json
echo -e "${GREEN}Generating results json file${NC}"
if [ "$dry_run" != "true" ]; then
  source ./generateOutputJSON.sh
fi
echo ""

# Removing clusters
echo -e "${GREEN}Removing clusters${NC}"
if [ "$dry_run" != "true" ]; then
  source ./removeClusters.sh
fi
echo ""
