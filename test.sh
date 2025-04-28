#!/bin/bash

#empty_variable=("")

# Check if 'empty_variable' is unset
if [ -z "${empty_variable+x}" ]; then
  echo "empty_variable is unset. Exiting."
  exit 1
fi

# If set (even to empty string), continue
echo "empty_variable is set. Proceeding."

# Rest of your script here
