#!/bin/bash

docker run -ti -v ~/nephele-scheduling-benchmarking/results/${experiment_name}/:/root/results/ swnuom/output-results /root/plotall.sh 
