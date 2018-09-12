NEWNODE=$1
MANAGER=$2
  
docker -H=tcp://$NEWNODE:2376 swarm join --token $(docker -H=tcp://$MANAGER:2376 swarm join-token worker -q) $MANAGER