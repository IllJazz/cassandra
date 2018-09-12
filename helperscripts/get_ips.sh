#########################################
# get Hosts with label 'cassandra=true' #
for NODE in $(docker node ls | grep Ready | awk '{print $1}')
do 
 # get Hosts with label 'cassandra=true' #
 DATA=$(docker node inspect $NODE | grep '"cassandra": "true"')
 if [ ! -z "$DATA" ]
 then
  NODES="${NODES} $(docker node inspect $NODE --format '{{ .Status.Addr  }}')"
 fi
done
#########################################

for HOST in $NODES
do
 echo "$HOST running Cassandra@$(docker -H=tcp://$HOST:2376 inspect \
 --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
 $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}'))"
# $(docker -H=tcp://$HOST:2376 ps -q)
done