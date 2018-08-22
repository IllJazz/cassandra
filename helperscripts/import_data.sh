#!/bin/sh

# get Cassandra hosts (Worker-Nodes) from Manager
NODES=$(docker node inspect $(docker node ls -f "role=Worker" -q) --format '{{ .Status.Addr  }}')
NUMBER_OF_HOSTS=$(echo $NODES | wc -w)
#FILENAME=$1
FILENAME=export_ilja_10.csv
ARCHIVENAME=$FILENAME".gz"

# unzip on Manager
 #cd $HOME/projects/cassandra_cluster/testdata
 #"C:\Program Files\7-Zip\7z.exe" x $ARCHIVENAME
 #split --number=l/3 --numeric=1 --additional-suffix=".csv" $FILENAME "import"
 #rm $FILENAME
# oder mit Pipe (feste Zeilenanzahl)
# "C:\Program Files\7-Zip\7z.exe" x $HOME/projects/cassandra_cluster/testdata/export_ilja_10.csv.gz -so | split -l 3333334 --numeric=1 --additional-suffix=".csv" - $HOME/projects/cassandra_cluster/testdata/import

# copy to host machine NUMBER_OF_HOSTS
i=1
for HOST in $NODES
do
 echo "Copying data to host $HOST ..."
 scp $HOME/projects/cassandra_cluster/testdata/import0$i.csv docker@$HOST:/home/docker/import.csv
 echo "done"
 echo "Copying to Container"
 ssh docker@$HOST "docker cp /home/docker/import.csv $(docker -H=tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}'):/var/lib/cassandra"
 i=$((i + 1))
 echo "done"
done 
# && \
#docker cp /home/docker/import $(docker -H=tcp://192.168.99.102:2376 ps | grep cassandra | awk '{print $1}'):/var/lib/cassandra/import.csv.gz"
