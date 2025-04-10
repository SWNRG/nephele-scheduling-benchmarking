#!/bin/bash

curl -X POST "http://127.0.0.1:8000/placement?context=cluster1" \
-H "Content-Type: application/json" \
-d '{
    "cluster": "cluster3",
    "services": [
{"id": "heavymemory1", "cpu": "light", "memory": "large"},
{"id": "heavycpu1", "cpu": "large", "memory": "light"}
    ],
    "graph_descriptor": {
"heavymemory1": {"dependencies": ["heavycpu"]},
"heavycpu1": {"dependencies": []}
    }
}'
