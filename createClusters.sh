#!/bin/bash
# input:
# cluster_names
# cluster_nodes
# cluster_cpu
# cluster_memory
# cluster_pods
# output:
# creates multiple k8s clusters

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

# cluster_pods variable should be specified
if [ -z "$cluster_pods" ]; then
    echo "cluster_pods variable should be specified"
    exit 1
fi


create_clusters () {
  # create clusters
  for i in "${!cluster_names[@]}"; do
    cluster_name="${cluster_names[$i]}"

    echo "Creating ${cluster_name}"
    kwokctl create cluster --name="${cluster_name}" --enable-metrics-server -c "${METRICS_CONFIG}" -c "${ANNOTATED_RESOURCES}"
 # kwokctl scale node --name="${cluster_name}" --replicas 2
  done

  # Creating nodes to clusters
  echo -e "${GREEN}Creating nodes to clusters${NC}"

  for i in "${!cluster_names[@]}"; do
    cluster_name="${cluster_names[$i]}"
    replica_count="${cluster_nodes[$i]}"
    node_cpu="${cluster_cpu[$i]}"
    node_memory="${cluster_memory[$i]}"
    node_pods="${cluster_pods[$i]}"

    for k in $(seq 1 $replica_count); do

      kwokctl --name=$cluster_name kubectl apply -f - <<EOF
apiVersion: v1
kind: Node
metadata:
  annotations:
    node.alpha.kubernetes.io/ttl: "0"
    kwok.x-k8s.io/node: fake
    metrics.k8s.io/resource-metrics-path: /metrics/nodes/kwok-node-$k/metrics/resource
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: kwok-node-$k
    kubernetes.io/os: linux
    kubernetes.io/role: agent
    node-role.kubernetes.io/agent: ""
    type: kwok
  name: kwok-node-$k
spec:
  taints: # Avoid scheduling actual running pods to fake Node
  - effect: NoSchedule
    key: kwok.x-k8s.io/node
    value: fake
status:
  allocatable:
    cpu: $node_cpu
    memory: $node_memory
    pods: $node_pods
  capacity:
    cpu: $node_cpu
    memory: $node_memory
    pods: $node_pods
  nodeInfo:
    architecture: amd64
    bootID: ""
    containerRuntimeVersion: ""
    kernelVersion: ""
    kubeProxyVersion: fake
    kubeletVersion: fake
    machineID: ""
    operatingSystem: linux
    osImage: ""
    systemUUID: ""
  phase: Running
EOF
    done
  done
}
