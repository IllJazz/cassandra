##########################
# Cassandra Startup Script
##########################
set -e
# Create Network
NETEX=$(docker network ls | grep casnet | awk '{print $2}')
if [[ ! $NETEX=="casnet" ]]; then
  echo "=============================="
  echo "== Creating Overlay Network =="
  echo "=============================="
docker network create -d overlay --attachable casnet
else 
  echo "== Network allready exists =="
fi
# Start first instance
echo "=============================="
echo "= Starting Cassandra Cluster ="
echo "=============================="
docker service create \
  --name cassandra \
  --network casnet \
  -e HEAP_NEWSIZE=12M \
  -e MAX_HEAP_SIZE=64M \
  --mode=global \
  --constraint 'node.labels.cassandra==true' \
  --mount type=volume,source=casdata,destination=/var/lib/cassandra/ \
  192.168.99.100:5000/casfork

    #--placement-pref 'spread=node.labels.cassandra' \
  
  
# Scaling up
if [ "$1" ]
then
  i=2
  while [ "$i" -le "$1" ]; do
    printf '%s\n' "Scaling up ..."
    docker service scale cassandra=$i
    i=$((i + 1))
    echo "Waiting for gossip to settle ..."
    sleep 20
  done
fi
# Showing Tasks
docker service ps cassandra
sleep 10

# Nodetool on Seed
echo "======================="
docker exec -it $(docker ps | grep cassandra | awk '{print $1}') nodetool status
