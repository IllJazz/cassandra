NODES=""
for NODE in $(docker node ls -q)
do 
 DATA=$(docker node inspect $NODE | grep '"cassandra": "true"')
 if [ ! -z "$DATA" ]
 then
  NODES="${NODES} $(docker node inspect $NODE --format '{{ .Status.Addr  }}')"
 fi
done

echo $NODES