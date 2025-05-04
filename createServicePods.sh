#!/bin/bash
# input:
# services_names
# services_replicas
# services_placements
# translated_services_cpu
# translated_services_memory
# output:
# creates service pods

# services_names variable should be specified
if [ -z "$services_names" ]; then
    echo "services_names variable should be specified"
    exit 1
fi

# translated_services_cpu variable should be specified
if [ -z "$translated_services_cpu" ]; then
    echo "translated_services_cpu variable should be specified"
    exit 1
fi

# translated_services_memory variable should be specified
if [ -z "$translated_services_memory" ]; then
    echo "translated_services_memory variable should be specified"
    exit 1
fi

# services_placements variable should be specified
if [ -z "$services_placements" ]; then
    echo "services_placements variable should be specified"
    exit 1
fi

# services_replicas variable should be specified
if [ -z "$services_replicas" ]; then
    echo "services_replicas variable should be specified"
    exit 1
fi


create_service_pods() {
  local z=0

  for i in "${!services_names[@]}"; do

    replicas="${services_replicas[$i]}"

    for k in $(seq 1 $replicas); do
      service_name="${services_names[$i]}$k"
      cluster="${services_placements[$z]}"
      cpu="${translated_services_cpu[$i]}"
      memory="${translated_services_memory[$i]}"

      # calculate appropriate placement number
      #p=$((i + k - 1))
      placement="${placements[$z]}"

      echo "Service $service_name is being placed in cluster $cluster and node $placement"

      # create service pod with particular resource utilization
      kwokctl --name=$cluster kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $service_name
  namespace: default
  annotations:
    kwok.x-k8s.io/usage-cpu: "$cpu"
    kwok.x-k8s.io/usage-memory: "$memory"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $service_name
  template:
    metadata:
      annotations:
        kwok.x-k8s.io/usage-cpu: "$cpu"
        kwok.x-k8s.io/usage-memory: "$memory"
      labels:
        app: $service_name
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: "kubernetes.io/hostname"
                operator: In
                values:
                - $placement
      # A taints was added to an automatically created Node.
      # You can remove taints of Node or add this tolerations.
      tolerations:
      - key: "kwok.x-k8s.io/node"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
      - name: $service_name
        image: fake-image
EOF
    ((z++))
    done
  done
}
