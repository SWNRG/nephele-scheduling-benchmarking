#!/bin/bash

case $run_id in
  "light-cpu")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("64Gi" "128Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("lightcpua lightcpub lightcpuc lightcpud lightcpue" "lightcpuf lightcpug lightcpuh lightcpui lightcpuj")
    services_dependencies_sets=("lightcpub lightcpua lightcpua lightcpua lightcpua" "lightcpua lightcpua lightcpua lightcpua lightcpua")
    services_cpu_sets=("light light light light light" "light light light light light") # total cpu is (7.5 + 7.5) * 11 = 165
    services_memory_sets=("light light light light light" "light light light light light")
    services_replicas_sets=("11 11 11 11 11" "11 11 11 11 11")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;;
	       
  "medium-cpu")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("64Gi" "128Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("mediumcpua mediumcpub mediumcpuc mediumcpud mediumcpue" "mediumcpuf mediumcpug mediumcpuh mediumcpui mediumcpuj")
    services_dependencies_sets=("mediumcpub mediumcpua mediumcpua mediumcpua mediumcpua" "mediumcpua mediumcpua mediumcpua mediumcpua mediumcpua")
    services_cpu_sets=("medium medium medium medium medium" "medium medium medium medium medium") # total cpu is (20 + 20) * 4 = 160
    services_memory_sets=("light light light light light" "light light light light light")
    services_replicas_sets=("4 4 4 4 4" "4 4 4 4 4")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;;

  "large-cpu")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("64Gi" "128Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("largecpua largecpub largecpuc largecpud largecpue" "largecpuf largecpug largecpuh largecpui largecpuj")
    services_dependencies_sets=("largecpub largecpua largecpua largecpua largecpua" "largecpua largecpua largecpua largecpua largecpua")
    services_cpu_sets=("large large large large large" "large large large large large") # total cpu is 64 * 2 = 128
    services_memory_sets=("light light light light light" "light light light light light")
    services_replicas_sets=("2 2 2 2 2" "2 2 2 2 2")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;;

  "mixture-cpu")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("64Gi" "128Gi" "256Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("lightcpua mediumcpub lightcpuc lightcpud largecpue" "lightcpuf mediumcpug lightcpuh largecpui lightcpuj")
    services_dependencies_sets=("mediumcpub lightcpua lightpua lightcpua lightcpua" "lightcpua lightcpua lightcpua lightcpua lightcpua")
    services_cpu_sets=("light medium light light large" "light medium light large light") # total cpu is (1.5 + 4 + 8 + 1.5 + 4 + 8)*6 = 162
    services_memory_sets=("light light light light light" "light light light light light")
    services_replicas_sets=("6 6 6 6 6" "6 6 6 6 6")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;;


  "light-memory")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("16Gi" "32Gi" "48Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("lightmema lightmemb lightmemc lightmemd lightmeme" "lightmemf lightmemg lightmemh lightmemi lightmemj")
    services_dependencies_sets=("lightmemb lightmema lightmema lightmema lightmema" "lightmema lightmema lightmema lightmema lightmema")
    services_cpu_sets=("medium medium medium medium medium" "medium medium medium medium medium") # total cpu is (20 + 20) * 4 = 160
    services_memory_sets=("light light light light light" "light light light light light")
    services_replicas_sets=("4 4 4 4 4" "4 4 4 4 4")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;;

  "medium-memory")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("16Gi" "32Gi" "48Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("mediummema mediummemb mediummemc mediummemd mediummeme" "mediummemf mediummemg mediummemh mediummemi mediummemj")
    services_dependencies_sets=("mediummemb mediummema mediummema mediummema mediummema" "mediummema mediummema mediummema mediummema mediummema")
    services_cpu_sets=("medium medium medium medium medium" "medium medium medium medium medium") # total cpu is (20 + 20) * 4 = 160
    services_memory_sets=("medium medium medium medium medium" "medium medium medium medium medium")
    services_replicas_sets=("4 4 4 4 4" "4 4 4 4 4")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;; 

  "large-memory")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("16Gi" "32Gi" "48Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("largemema largememb largememc largememd largememe" "largememf largememg largememh largememi largememj")
    services_dependencies_sets=("largememb largemema largemema largemema largemema" "largemema largemema largemema largemema largemema")
    services_cpu_sets=("medium medium medium medium medium" "medium medium medium medium medium") # total cpu is (20 + 20) * 4 = 160
    services_memory_sets=("large large large large large" "large large large large large")
    services_replicas_sets=("4 4 4 4 4" "4 4 4 4 4")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;; 

 "mixture-memory")
    cluster_names=("cluster1" "cluster2" "cluster3")
    cluster_nodes=(2 3 4)
    cluster_cpu=(8 16 32) # total cpu is 16+48+128=192 
    cluster_memory=("16Gi" "32Gi" "48Gi")
    cluster_pods=(100 100 100)
    cluster_gpus=(0 0 0 0 0)

    services_names_sets=("lightmema mediummemb lightmemc lightmemd largememe" "lightmemf mediummemg lightmemh largememi lightmemj")
    services_dependencies_sets=("mediummemb lightmema lightmema lightmema lightmema" "lightmema lightmema lightmema lightmema lightmema")
    services_cpu_sets=("medium medium medium medium medium" "medium medium medium medium medium") # total cpu is (20 + 20) * 4 = 160
    services_memory_sets=("light medium light light large" "light medium light large light")
    services_replicas_sets=("4 4 4 4 4" "4 4 4 4 4")
    services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0")
    ;;

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
    services_replicas_sets=("30 30 30 30 30" "30 30 30 30 30")

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
