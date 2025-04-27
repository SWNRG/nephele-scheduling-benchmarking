#!/bin/bash
# input:
# service json string
# output:
# cluster placement output

# json variable should be specified
if [ -z "$json" ]; then
    echo "json variable should be specified"
    exit 1
fi

# request cluster placement
response=$(curl -X POST "http://127.0.0.1:8000/clusterplacement" \
-H "Content-Type: application/json" \
-d "$json")

if ! echo "$response" | jq . >/dev/null 2>&1; then
  echo -e "${RED}Error: Invalid response from scheduler:${NC}"
  echo "$response"
  exit 1
fi

echo "response is: $response"
