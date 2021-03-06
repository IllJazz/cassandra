# Probleme
removing dead nodes via nodetool removenode ...
# clean system 
docker system prune
docker volume prune
docker swarm init --advertise-addr 192.168.99.101
docker network create -d overlay --scope swarm --attachable cassandra-net
docker stack deploy -c compose.yml cas # doesnt work in swarm mode

# on seed
docker exec -it $(docker ps | grep cassandra.1 | awk '{print $1}') nodetool status
docker exec -ti $(docker ps -q)  nodetool status
docker exec -ti cassandra.1.$(docker service ps -f 'name=cassandra.1' cassandra -q --no-trunc | head -n1) nodetool status
# on worker
docker exec -ti $(docker ps -q) cat /etc/cassandra/cassandra.yaml | grep seed
docker exec -it $(docker ps | grep cassandra.4 | awk '{print $1}') cat /etc/cassandra/cassandra.yaml | grep seed
  # on windows powershell
  docker exec -ti $(docker ps -q) cat /etc/cassandra/cassandra.yaml | select-string seed

# get ip's
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
docker service inspect --format='{{json .Endpoint.VirtualIPs}}' cas_cassandra1

# DiagnoseTools 
apt-get update && \
apt-get install inetutils-ping -y && \
apt-get install dnsutils -y && \
apt-get install net-tools -y

# Service Übersicht
docker service ps -f "desired-state=running" cassandra
docker service ps -f "desired-state=running" --format "{{.Name}}@{{.Node}}: {{.CurrentState}}" cassandra

# copy yaml file
docker cp $(docker ps -q):/etc/cassandra/cassandra.yaml ./worker/
git config --global user.email "illjazz@gmx.de"
git commit -a -m "update yaml"
git push
docker run --rm -ti -v /home/docker/cassandra/worker:/source -v cas_casconfig2:/target alpine sh -c 'cp /source/cassandra.yaml /target/cassandra.yaml' 


# cassandra fork
docker service create \
  --name cassandra \
  --network casnet \
  -e HEAP_NEWSIZE=12M \
  -e MAX_HEAP_SIZE=64M \
  192.168.99.100:5000/casfork
# webscam/cassandra:swarm_test (original)
  # onwindows
  docker service create --name cassandra --network mynetwork 192.168.99.100:5000/casfork


# images from local registry
docker stack deploy -c docker-compose.yml --with-registry-auth

# using constraints
--constraint 'node.role == worker' # only on worker nodes

# Webinterface
docker run -d --name cassandra-web \
-e CASSANDRA_HOST_IP=192.168.99.101 \
-e CASSANDRA_PORT=9042 \
-e CASSANDRA_USERNAME=user \
-e CASSANDRA_PASSOWRD=pass \
-p 3000:3000 \
delermando/docker-cassandra-web:v0.4.0
  # on Windows
  docker run -d --name cassandra-web -e CASSANDRA_HOST_IP=192.168.99.101 -e CASSANDRA_PORT=9042 -p 3000:3000 delermando/docker-cassandra-web:v0.4.0
  docker run -d --rm --net casnet --name cassandra-web -e CASSANDRA_HOST_IP=10.0.2.104 -e CASSANDRA_PORT=9042 -p 3000:3000 192.168.99.100:5000/casweb