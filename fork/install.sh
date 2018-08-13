PROG=$1
docker exec -it -e PROG $(docker ps | grep cassandra | awk '{print $1}') bash -c "apt-get update && apt-get install $PROG"