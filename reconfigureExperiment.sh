#!/bin/bash

case $run_id in

  "replica-1")
    services_replicas_sets=("1 1 1 1 1" "1 1 1 1 1")

    services_names_sets=("mediuma mediumb mediumc mediumd mediume" "mediumf mediumg mediumh mediumi mediumj")
    services_dependencies_sets=("mediumb mediuma mediuma mediuma mediuma" "mediuma mediuma mediuma mediuma mediuma")
    services_cpu_sets=("light light light light light" "light light light light light") # total cpu is 5 * 50 = 50
    services_memory_sets=("medium medium medium medium medium" "medium medium medium medium medium")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")

    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 2 2)
    cluster_cpu=(32 32 32) # total cpu is 3 * 64 
    cluster_memory=("256Gi" "256Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)
    ;;

  "replicas-5")
    services_replicas_sets=("5 5 5 5 5" "5 5 5 5 5")

    services_names_sets=("mediuma mediumb mediumc mediumd mediume" "mediumf mediumg mediumh mediumi mediumj")
    services_dependencies_sets=("mediumb mediuma mediuma mediuma mediuma" "mediuma mediuma mediuma mediuma mediuma")
    services_cpu_sets=("light light light light light" "light light light light light") # total cpu is 5 * 50 = 50
    services_memory_sets=("medium medium medium medium medium" "medium medium medium medium medium")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")

    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 2 2)
    cluster_cpu=(32 32 32) # total cpu is 3 * 64 
    cluster_memory=("256Gi" "256Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)
    ;;

  "replicas-10")
    services_replicas_sets=("10 10 10 10 10" "10 10 10 10 10")

    services_names_sets=("mediuma mediumb mediumc mediumd mediume" "mediumf mediumg mediumh mediumi mediumj")
    services_dependencies_sets=("mediumb mediuma mediuma mediuma mediuma" "mediuma mediuma mediuma mediuma mediuma")
    services_cpu_sets=("light light light light light" "light light light light light") # total cpu is 5 * 50 = 50
    services_memory_sets=("medium medium medium medium medium" "medium medium medium medium medium")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")

    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 2 2)
    cluster_cpu=(32 32 32) # total cpu is 3 * 64 
    cluster_memory=("256Gi" "256Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)
    ;;

  "replicas-20")
    services_replicas_sets=("20 20 20 20 20" "20 20 20 20 20")

    services_names_sets=("mediuma mediumb mediumc mediumd mediume" "mediumf mediumg mediumh mediumi mediumj")
    services_dependencies_sets=("mediumb mediuma mediuma mediuma mediuma" "mediuma mediuma mediuma mediuma mediuma")
    services_cpu_sets=("light light light light light" "light light light light light") # total cpu is 5 * 50 = 50
    services_memory_sets=("medium medium medium medium medium" "medium medium medium medium medium")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")

    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 2 2)
    cluster_cpu=(32 32 32) # total cpu is 3 * 64 
    cluster_memory=("256Gi" "256Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)
    ;;

  "replicas-30")
    services_replicas_sets=("20 20 20 20 20" "20 20 20 20 20")

    services_names_sets=("mediuma mediumb mediumc mediumd mediume" "mediumf mediumg mediumh mediumi mediumj")
    services_dependencies_sets=("mediumb mediuma mediuma mediuma mediuma" "mediuma mediuma mediuma mediuma mediuma")
    services_cpu_sets=("light light light light light" "light light light light light") # total cpu is 5 * 50 = 50
    services_memory_sets=("medium medium medium medium medium" "medium medium medium medium medium")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")

    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 2 2)
    cluster_cpu=(32 32 32) # total cpu is 3 * 64 
    cluster_memory=("256Gi" "256Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)
    ;;


  "clusters-3")
    cluster_names=("cluster1" "cluster2" "cluster3")  
    cluster_nodes=(2 2 2) 
    cluster_cpu=(32 32 32)  # total cpu is 3 * 64 = 192
    cluster_memory=("256Gi" "256Gi" "256Gi")  
    cluster_pods=(100 100 100)   
    cluster_gpus=(0 0 0)

    services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediummemory secondlightcpu") 
    services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
    services_cpu_sets=("light light light light light" "medium light large light light") # total cpu is (7.5 + 13.5) * 10 = 210
    services_memory_sets=("light large light medium light" "light large light medium light")
    services_replicas_sets=("10 10 10 10 10" "10 10 10 10 10")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
    ;;

  "clusters-5")
    cluster_names=("cluster1" "cluster2" "cluster3" "cluster4" "cluster5")  
    cluster_nodes=(2 2 2 2 2) 
    cluster_cpu=(32 32 32 32 32) # total cpu is 5 * 64 = 320
    cluster_memory=("256Gi" "256Gi" "256Gi" "256Gi" "256Gi")  
    cluster_pods=(100 100 100 100 100)   
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediumcpu secondlightcpu") 
    services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
    services_cpu_sets=("light light light light light" "medium light large medium light") # total cpu is 21 * 13 = 294
    services_memory_sets=("light large light medium light" "light large light light light")
    services_replicas_sets=("13 13 13 13 13" "13 13 13 13 13") 
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
    ;;

  "clusters-10")
    cluster_names=("cluster1" "cluster2" "cluster3" "cluster4" "cluster5" "cluster6" "cluster7" "cluster8" "cluster9" "cluster10")  
    cluster_nodes=(2 2 2 2 2 2 2 2 2 2) 
    cluster_cpu=(32 32 32 32 32 32 32 32 32 32)  # total cpu is 640
    cluster_memory=("256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi" "256Gi")  
    cluster_pods=(100 100 100 100 100 100 100 100 100 100)   
    cluster_gpus=(0 0 0 0 0 0 0 0 0 0)

    services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediumcpu secondlightcpu") 
    services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
    services_cpu_sets=("light light light light light" "medium light large medium light") # total cpu is 21 * 28 = 588
    services_memory_sets=("light large light medium light" "light large light light light")
    services_replicas_sets=("21 21 21 21 21" "21 21 21 21 21") 
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
    ;;

  *)
    echo "Unknown run_id"
    exit 1
    ;;
esac
