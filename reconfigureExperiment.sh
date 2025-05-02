#!/bin/bash

case $run_id in

  "replica-1")
    services_replicas_sets=("1 1 1" "1 1 1") # number of times to replicate each service
    ;;

  "replicas-5")
    services_replicas_sets=("5 5 5" "5 5 5") # number of times to replicate each service
    ;;

  "replicas-10")
    services_replicas_sets=("10 10 10" "10 10 10") # number of times to replicate each service
    ;;

  *)
    echo "Unknown run_id"
    exit 1
    ;;
esac
