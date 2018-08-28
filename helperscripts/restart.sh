HOST=$1
docker -H tcp://$HOST:2376 container rm --force $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}')
docker service update cassandra