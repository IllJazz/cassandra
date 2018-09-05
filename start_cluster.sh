# starting Docker Hosts
start() {
docker-machine start default &
sleep 5
docker-machine start cassandra1 &
sleep 5
docker-machine start cassandra2 &
sleep 5
docker-machine start cassandra3 &
wait $!
}

showIPs() {
HOSTS=$(docker-machine ls -q)
for HOST in $HOSTS
do
echo $HOST": " $(docker-machine inspect $HOST | grep IP)
done
}

showIPs