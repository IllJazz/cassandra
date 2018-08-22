# Portainer Web-Frontend for Managing Docker
# docker volume create portainer_data <Volume muss auf richtigem Host gemountet werden>
docker service create \
--name portainer \
--publish 9000:9000 \
--replicas=1 \
--constraint 'node.labels.portainer == true' \
--mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
--mount type=volume,src=portainer_data,dst=/data \
portainer/portainer \
-H unix:///var/run/docker.sock