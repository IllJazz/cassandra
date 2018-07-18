echo "Removing Cassandra Cluster Service"
docker service rm cassandra
sleep 5
echo "Cleaning Containers and Volumes"
docker system prune -f
docker volume prune -f

