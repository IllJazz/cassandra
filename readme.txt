# clean system
docker system prune
docker volume prune
docker swarm init --advertise-addr 192.168.99.101
docker network create -d overlay --scope swarm --attachable cassandra-net
docker stack deploy -c compose.yml cas
# on seed
docker exec -ti $(docker ps -q)  nodetool status
# on worker
docker exec -ti $(docker ps -q) cqlsh cassandra1

# get ip (doesnt work in swarm)
docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -q)

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
