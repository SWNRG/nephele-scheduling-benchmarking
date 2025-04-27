#!/bin/bash
# input:
# cluster_names
# cluster_nodes
# cluster_cpu
# cluster_memory
# output:
# cluster_cpu_utilization
# cluster_node_utilization
# cluster_memory_utilization
# node_cpu_utilization
# node_memory_utilzation

# cluster_names variable should be specified
if [ -z "$cluster_names" ]; then
    echo "cluster_names variable should be specified"
    exit 1
fi

# cluster_nodes variable should be specified
if [ -z "$cluster_nodes" ]; then
    echo "cluster_nodes variable should be specified"
    exit 1
fi

# cluster_cpu variable should be specified
if [ -z "$cluster_cpu" ]; then
    echo "cluster_cpu variable should be specified"
    exit 1
fi

# cluster_memory variable should be specified
if [ -z "$cluster_memory" ]; then
    echo "cluster_memory variable should be specified"
    exit 1
fi

declare -A cluster_cpu_utilization
declare -A cluster_node_utilization
declare -A cluster_memory_utilization
declare -A node_cpu_utilization
declare -A node_memory_utilization

for i in "${!cluster_names[@]}"; do
  cluster="${cluster_names[$i]}"
  nodes=${cluster_nodes[$i]}
  echo -e "${YELLOW}Fetching metrics for $cluster${NC}"

  node_metrics=$(kwokctl --name=$cluster kubectl top nodes --no-headers 2>/dev/null)

  total_cpu=0
  total_mem=0
  total_cpu_capacity=$((cluster_cpu[$i] * 1000 * nodes))  # assuming 'm' (millicores)

  total_mem_capacity=$(echo "${cluster_memory[$i]}" | sed 's/Gi//' | awk '{ print $1 * 1024 * 1024 }')
  total_mem_capacity=$((total_mem_capacity * nodes))  # in Ki

  used_nodes=0

  if [[ -z $node_metrics ]]; then
    # empty results, probably metrics server is not sending measurements yet
    echo "Empty results, probably metrics server is not sending measurements yet"
  else
    while read -r line; do
      node_name=$(echo "$line" | awk '{print $1}')
      cpu_usage=$(echo "$line" | awk '{print $2}' | sed 's/m//')
      mem_usage_raw=$(echo "$line" | awk '{print $3}')

      if [[ "$cpu_usage" == "<unknown>" || "$mem_usage_raw" == "<unknown>" ]]; then
	# skip node, it has unknown resources.
        continue
      fi

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

      total_cpu=$((total_cpu + cpu_usage))
      total_mem=$((total_mem + mem_usage))
      used_nodes=$((used_nodes + 1))
    done <<< "$node_metrics"
  fi

  cluster_cpu_utilization["$cluster"]=$((total_cpu * 100 / total_cpu_capacity))
  cluster_memory_utilization["$cluster"]=$((total_mem * 100 / total_mem_capacity))
  cluster_node_utilization["$cluster"]=$((used_nodes * 100 / nodes))
done
