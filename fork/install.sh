PROG=$1
docker exec -it -e PROG $(docker ps | grep cassandra | awk '{print $1}') apt-get install $PROG