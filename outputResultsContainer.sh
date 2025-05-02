#!/bin/bash

docker run -ti -v ~/codeco-experiments/results/${experiment_name}/:/root/results/ swnuom/output-results /root/plotall.sh 
