#!/bin/bash

case $run_id in

  "clusters-3")
    cluster_names=("cluster1" "cluster2" "cluster3")  # name of clusters
    cluster_nodes=(2 2 2) # number of nodes per cluster
    cluster_cpu=(32 32 32)  # cpu of cluster nodes
    cluster_memory=("256Gi" "256Gi" "256Gi")  # memory of cluster nodes
    cluster_pods=(100 100 100)   # maximum number of pods to allocate
    cluster_gpus=(0 0 0)
    ;;

  "clusters-5")
    cluster_names=("cluster1" "cluster2" "cluster3" "cluster4" "cluster5")  # name of clusters
    cluster_nodes=(2 2 2 2 2) # number of nodes per cluster
    cluster_cpu=(32 32 32 32 32)  # cpu of cluster nodes
    cluster_memory=("256Gi" "256Gi" "256Gi" "256Gi" "256Gi")  # memory of cluster nodes
    cluster_pods=(100 100 100 100 100)   # maximum number of pods to allocate
    cluster_gpus=(0 0 0 0 0)
    ;;

  "clusters-10")
    cluster_names=("cluster1" "cluster2" "cluster3" "cluster4" "cluster5" "clustr6" "cluster7" "cluster8" "cluster9" "cluster10")  # name of clusters
    cluster_nodes=(2 2 2 2 2 2 2 2 2 2) # number of nodes per cluster
    cluster_cpu=(32 32 32 32 32 32 32 32 32 32)  # cpu of cluster nodes
    cluster_memory=("256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi")  # memory of cluster nodes
    cluster_pods=(100 100 100 100 100 100 100 100 100 100)   # maximum number of pods to allocate
    cluster_gpus=(0 0 0 0 0 0 0 0 0 0)
    ;;

  *)
    echo "Unknown run_id"
    exit 1
    ;;
esac
