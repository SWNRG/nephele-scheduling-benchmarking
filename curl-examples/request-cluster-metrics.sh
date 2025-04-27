#!/bin/bash

echo "Requesting resources of cluster1"
curl -X GET "http://127.0.0.1:8000/clustermetrics?context=cluster1" 
echo ""
echo "Requesting resources of all clusters"
curl -X GET "http://127.0.0.1:8000/clustermetrics"
