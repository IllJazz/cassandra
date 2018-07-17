# clean system
docker system prune
docker volume prune
docker swarm init --advertise-addr 192.168.99.101
docker network create -d overlay --scope swarm --attachable cassandra-net
docker stack deploy -c compose.yml cas
# on seed
docker exec -ti $(docker ps -q)  nodetool status
# on worker
docker exec -ti $(docker ps -q) cat /etc/cassandra/cassandra.yaml | grep seed

# get ip's
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
docker service inspect --format='{{json .Endpoint.VirtualIPs}}' cas_cassandra1

# DiagnoseTools 
apt-get update && \
apt-get install inetutils-ping -y && \
apt-get install dnsutils -y && \
apt-get install net-tools -y

# copy yaml file
docker cp $(docker ps -q):/etc/cassandra/cassandra.yaml ./worker/
git config --global user.email "illjazz@gmx.de"
git commit -a -m "update yaml"
git push
docker run --rm -ti -v /home/docker/cassandra/worker:/source -v cas_casconfig2:/target alpine sh -c 'cp /source/cassandra.yaml /target/cassandra.yaml' 


# cassandra fork
docker service create \
  --name cassandra \
  --network mynetwork \
  -e HEAP_NEWSIZE=12M \
  -e MAX_HEAP_SIZE=64M \
webscam/cassandra:swarm_test

# images from local registry
docker stack deploy -c docker-compose.yml --with-registry-auth