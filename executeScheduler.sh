#!/bin/bash
# Executes scheduler container after compiling it and removing
# its previous instance, if it exists

# build scheduler
docker build -t scheduler . 2> /dev/null > /dev/null

# stop and remove existing instance (if needed)
docker stop scheduler 2> /dev/null > /dev/null
docker remove scheduler 2> /dev/null > /dev/null

# execute scheduler as a daemon
docker run --name scheduler --net=host -v /home/user/.kube/config:/root/.kube/config -v /home/user/.kwok/:/home/user/.kwok/ scheduler
