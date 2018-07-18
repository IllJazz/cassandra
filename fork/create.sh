# Cassandra Cluster StartUp Script
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
    echo "To scale service manually type: docker service scale cassandra=<number of replicas>"
  else
    if [ $1 == "1" ]
	then
	else 
		for ((i=2;i<=$1;i++))
		do
		  echo "Scaling up to $i instances"
		  sleep 20
		  docker service scale cassandra=$i
		done
	fi
fi
