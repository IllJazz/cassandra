#!/bin/bash
# Cassandra Cluster StartUp Script
set -x
echo "Starting Single Cassandra Node"
docker network create -d overlay --attachable casnet
docker service create \
  --name cassandra \
  --network casnet \
  -e HEAP_NEWSIZE=12M \
  -e MAX_HEAP_SIZE=64M \
  192.168.99.100:5000/casfork

for ((i = 1; i <= $#; i++ )); do
  printf '%s\n' "Arg $i: ${(P)i}"
done
