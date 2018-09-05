before=$(date +%s)
ORIGFILENAME="import"
KEYSPACE="test"
TABLE="test2"
FILENAME=$ORIGFILENAME"_"$KEYSPACE"_"$TABLE".err"
echo "Filename = $FILENAME"
#######################
# declare CQL Command # 
CQL="COPY $KEYSPACE.$TABLE (uuid1, number1, uuid2, date1, number2, boo1, number3, number4, number5, number6, date2) \
FROM '/var/lib/cassandra/$FILENAME' WITH HEADER = FALSE AND MINBATCHSIZE = 2 AND MAXBATCHSIZE = 10 AND CHUNKSIZE=1000 AND DATETIMEFORMAT=UNIXTIMESTAMP" 

#########################################
# get Hosts with label 'cassandra=true' #
for NODE in $(docker node ls -q)
do 
 DATA=$(docker node inspect $NODE | grep '"cassandra": "true"')
 if [ ! -z "$DATA" ]
 then
  NODES="${NODES} $(docker node inspect $NODE --format '{{ .Status.Addr  }}')"
 fi
done
#########################################

for HOST in $NODES
do
  ERR=$(docker -H tcp://$HOST:2376 exec $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') ls)
  ERR1=$(echo $ERR | grep $FILENAME)
  if [ ! -z "$ERR1" ]
  then
    echo "Importing failed data to host $HOST ..."
    docker -H tcp://$HOST:2376 exec $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') bash -c "sed 's/\.0//g' $FILENAME > /var/lib/cassandra/$FILENAME"
    docker -H tcp://$HOST:2376 exec $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') cqlsh -e "$CQL"
  fi
done

after=$(date +%s)
echo "elapsed time:" $((after - $before)) "seconds"