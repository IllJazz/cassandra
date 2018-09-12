# show Cassandra Log of Node
HOST=$1
docker -H tcp://$HOST:2376 logs \
$(docker -H tcp://$HOST:2376 ps \
| grep cassandra | awk '{print $1}')