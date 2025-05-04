#!/bin/bash

case $run_id in

  "clusters-3")
    cluster_names=("cluster1" "cluster2" "cluster3")  
    cluster_nodes=(2 2 2) 
    cluster_cpu=(32 32 32)  
    cluster_memory=("256Gi" "256Gi" "256Gi")  
    cluster_pods=(100 100 100)   
    cluster_gpus=(0 0 0)

    services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediummemory secondlightcpu") 
    services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
    services_cpu_sets=("light light light light light" "medium light large light light")
    services_memory_sets=("light large light medium light" "light large light medium light")
    services_replicas_sets=("10 10 10 10 10" "10 10 10 10 10")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
    ;;

  "clusters-5")
    cluster_names=("cluster1" "cluster2" "cluster3" "cluster4" "cluster5")  
    cluster_nodes=(2 2 2 2 2) 
    cluster_cpu=(32 32 32 32 32)  
    cluster_memory=("256Gi" "256Gi" "256Gi" "256Gi" "256Gi")  
    cluster_pods=(100 100 100 100 100)   
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediumcpu secondlightcpu") 
    services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
    services_cpu_sets=("light light light light light" "medium light large medium light")
    services_memory_sets=("light large light medium light" "light large light light light")
    services_replicas_sets=("10 10 10 10 10" "10 10 10 10 10") 
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
    ;;

  "clusters-10")
    cluster_names=("cluster1" "cluster2" "cluster3" "cluster4" "cluster5" "clustr6" "cluster7" "cluster8" "cluster9" "cluster10")  
    cluster_nodes=(2 2 2 2 2 2 2 2 2 2) 
    cluster_cpu=(32 32 32 32 32 32 32 32 32 32)  
    cluster_memory=("256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi")  
    cluster_pods=(100 100 100 100 100 100 100 100 100 100)   
    cluster_gpus=(0 0 0 0 0 0 0 0 0 0)

    services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediumcpu secondlightcpu") 
    services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
    services_cpu_sets=("light light light light light" "medium light large medium light")
    services_memory_sets=("light large light medium light" "light large light light light")
    services_replicas_sets=("10 10 10 10 10" "10 10 10 10 10") 
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
    ;;

  *)
    echo "Unknown run_id"
    exit 1
    ;;
esac
