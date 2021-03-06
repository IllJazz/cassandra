# Open Ports on VMs

    TCP port 2377 for cluster management communications
    TCP and UDP port 7946 for communication among nodes
    TCP and UDP port 4789 for overlay network traffic

# Create Machine
docker-machine create -d virtualbox --engine-insecure-registry 192.168.99.100:5000 --engine-label cassandra=true --swarm-host "tcp://192.168.99.100:3376" cassandra4


# New Swarm Node
docker-machine create --driver virtualbox --engine-insecure-registry 192.168.99.100:5000 cassandra<N>
 # ./join_vode.sh <new_ip> <master_ip> 
 docker -H=tcp://192.168.99.103:2376 swarm join --token $(docker -H=tcp://192.168.99.101:2376 swarm join-token worker -q) 192.168.99.101
 # on manager
 docker node update --label-add cassandra=true <new_node_name>

# clean system
docker system prune
docker volume prune
docker swarm init --advertise-addr 192.168.99.101
docker network create -d overlay --scope swarm --attachable cassandra-net
docker stack deploy -c compose.yml cas # doesnt work in swarm mode
# Watch Nodes
 # on seed
   docker exec -ti $(docker ps -q)  nodetool status
   docker exec -it $(docker ps | grep cassandra | awk '{print $1}') nodetool status
 # on worker
   docker exec -it $(docker ps | grep cassandra | awk '{print $1}') cat /etc/cassandra/cassandra.yaml | grep 'seeds:' | awk '{print$3}' | sed 's/"//g'
   docker exec -it $(docker ps | grep cassandra | awk '{print $1}') cat /etc/cassandra/cassandra.yaml | grep 'endpoint_snitch:' | awk '{print $2}'
     # on windows powershell
       docker exec -ti $(docker ps -q) cat /etc/cassandra/cassandra.yaml | select-string seed

# get ip's
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
docker service inspect --format='{{json .Endpoint.VirtualIPs}}' cassandra
# of other nodes
docker -H=tcp://192.168.99.102:2376 inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker -H=tcp://192.168.99.102:2376 ps -q)

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
  192.168.99.100:5000/casfork

# Adding Labels
 docker node update --label-add cassandra=true cassandra1  
  
# Adding Constraints
  # only deploy on workers
docker service update --constraint-add node.role==worker cassandra
docker service update --constraint-add 'node.labels.cassandra==true' cassandra
  
# webscam/cassandra:swarm_test (original)
  # onwindows
  docker service create --name cassandra --network mynetwork 192.168.99.100:5000/casfork


# images from local registry
docker stack deploy -c docker-compose.yml --with-registry-auth

# using constraints
--constraint 'node.role == worker' # only on worker nodes

# Diagnose
docker service ps -f desired-state=running cassandra
docker node inspect <NODENAME> --pretty

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
  # in swarm
docker run -d --net casnet --name casweb -p 3000:3000 192.168.99.100:5000/casweb

# row count java executable for installing in container
apt-get update && apt-get install wget
wget https://github.com/brianmhess/cassandra-count/releases/download/v0.0.6/cassandra-count
./cassandra-count -host 127.0.0.1 -keyspace test -table test2