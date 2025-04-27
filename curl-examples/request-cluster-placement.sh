#!/bin/bash

curl -X POST "http://127.0.0.1:8000/clusterplacement" \
-H "Content-Type: application/json" \
-d '{
    "cluster": "",
    "services": [
{"id": "lightmemory1", "cpu": "light", "memory": "light", "gpu": "0"},
{"id": "heavymemory1", "cpu": "light", "memory": "large", "gpu": "0"},
{"id": "lightcpu1", "cpu": "light", "memory": "light", "gpu": "0"},
{"id": "mediumcpu1", "cpu": "medium", "memory": "light", "gpu": "0"},
{"id": "heavymemory1", "cpu": "light", "memory": "large", "gpu": "0"},
{"id": "heavycpu1", "cpu": "large", "memory": "light", "gpu": "0"}
    ],
    "graph_descriptor": {
"lightmemory1": {"dependencies": ["heavymemory"]},
"heavymemory1": {"dependencies": []},
"lightcpu1": {"dependencies": ["mediumcpu"]},
"mediumcpu1": {"dependencies": []},
"heavymemory1": {"dependencies": ["heavycpu"]},
"heavycpu1": {"dependencies": []}
    }
}'
