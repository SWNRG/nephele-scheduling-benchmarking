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

# Define service slices configuration
services_names=("lightmemory" "heavymemory" "lightcpu" "mediumcpu" "heavymemory" "heavycpu")
# if services_placements is specified, it skips multi-cluster placement process
#services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")
services_dependencies=("heavymemory" "" "mediumcpu" "" "heavycpu" "")
services_cpu=("light" "light" "light" "medium" "light" "large")
services_memory=("light" "large" "light" "light" "large" "light")
services_replicas=(1 1 1 1 1 1) # number of times to replicate each service

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

services_placements=("cluster1" "cluster1" "cluster2" "cluster2" "cluster3" "cluster3")

echo ""

# Local cluster service placement (choosing cluster nodes per service)
echo -e "${GREEN}Placing services${NC}"
source ./placeServices.sh

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

# Removing clusters
echo -e "${GREEN}Removing clusters${NC}"
source ./removeClusters.sh

echo ""
