docker system prune
docker volume prune
docker swarm init --advertise-addr 192.168.99.101
docker network create -d overlay --scope swarm --attachable cassandra-net
