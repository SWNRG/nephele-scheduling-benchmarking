#!/bin/bash
# input:
# cluster_name (if empty return initial service, otherwise sliced)
# services_names
# services_cpu
# services_memory
# services_dependencies
# services_replicas
# services_gpus
# output:
# (sliced) service JSON

# services_names variable should be specified
if [ -z "$services_names" ]; then
    echo "services_names variable should be specified"
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

# services_dependencies variable should be set (empty string is allowed)
if [ -z "${services_dependencies[@]+x}" ]; then
    echo "services_dependencies variable should be specified"
    exit 1
fi

# services_replicas variable should be specified
if [ -z "$services_replicas" ]; then
    echo "services_replicas variable should be specified"
    exit 1
fi

# services_gpus variable should be specified
if [ -z "$services_gpus" ]; then
    echo "services_gpus variable should be specified"
    exit 1
fi

create_service_json() {
  local cluster_name=$1
  local services_json=""
  local graph_descriptor=""

  local z=0

  for i in "${!services_names[@]}"; do
    local service_id="${services_names[$i]}"
    local cpu="${services_cpu[$i]}"
    local memory="${services_memory[$i]}"
    local dependency="${services_dependencies[$i]}"
    local replicas="${services_replicas[$i]}"
    local gpu="${services_gpus[$i]}"

    for k in $(seq 1 $replicas); do
      if [[ "${services_placements[$z]}" == "$cluster_name" || -z "$cluster_name" ]]; then
        if [ -z "$services_json" ]; then
          services_json+="{\"id\": \"${service_id}$k\", \"cpu\": \"$cpu\", \"memory\": \"$memory\", \"gpu\": \"$gpu\"}"
        else
          services_json+=",\n{\"id\": \"${service_id}$k\", \"cpu\": \"$cpu\", \"memory\": \"$memory\", \"gpu\": \"$gpu\"}"
        fi

        if [[ -z "$graph_descriptor" ]]; then
          if [[ -n "$dependency" ]]; then
            graph_descriptor+="\"${service_id}$k\": {\"dependencies\": [\"$dependency\"]}"
          else
            graph_descriptor+="\"${service_id}$k\": {\"dependencies\": []}"
          fi
        else
          if [[ -n "$dependency" ]]; then
            graph_descriptor+=",\n\"${service_id}$k\": {\"dependencies\": [\"$dependency\"]}"
          else
            graph_descriptor+=",\n\"${service_id}$k\": {\"dependencies\": []}"
          fi
        fi
      fi
      ((z++))
    done
  done

  services_json=$(echo -e "$services_json")
  graph_descriptor=$(echo -e "$graph_descriptor")

  cat <<EOF
{
    "cluster": "$cluster_name",
    "services": [
$services_json
    ],
    "graph_descriptor": {
$graph_descriptor
    }
}
EOF
}
