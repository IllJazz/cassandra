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

if [ $1 == "" ]
  then
    echo "To scale service manually type 'docker service scale cassandra=<number of replicas>'"
fi
if [ $1 == "1" ]
  then
	echo "" 
else 
	z = 2
	while [ "$z" -le "$1" ]; do
	do
	  echo "Scaling up to $z instances"
	  sleep 20
	  docker service scale cassandra=$z
	  z=$((z + 1))
	done
fi