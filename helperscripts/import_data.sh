#!/bin/sh

# get Cassandra hosts (Worker-Nodes) from Manager
NODES=$(docker node inspect $(docker node ls -f "role=Worker" -q) --format '{{ .Status.Addr  }}')
NUMBER_OF_HOSTS=$(echo $NODES | wc -w)
#FILENAME=$1
FILENAME=export_ilja_10.csv
ARCHIVENAME=$FILENAME".gz"

#####
# Function for unzipping and splitting the Data-File on Manager Node
###
unzip() { 
 cd $HOME/projects/cassandra_cluster/testdata;
 "C:\Program Files\7-Zip\7z.exe" x $ARCHIVENAME;
 split --number=l/3 --numeric=1 --additional-suffix=".csv" $FILENAME "import";
 rm $FILENAME;
# oder mit Pipe (feste Zeilenanzahl)
# "C:\Program Files\7-Zip\7z.exe" x $HOME/projects/cassandra_cluster/testdata/export_ilja_10.csv.gz -so \
# | split -l 3333334 --numeric=1 --additional-suffix=".csv" - $HOME/projects/cassandra_cluster/testdata/import
}
#####

#####
# Old Function for copying data to the different Cassandra Nodes
###
copy_old() {
i=1;
for HOST in $NODES;
do
 echo "Copying data to host $HOST ...";
 scp $HOME/projects/cassandra_cluster/testdata/import0$i.csv docker@$HOST:/home/docker/import.csv;
 echo "done";
 echo "Copying to Container";
 ssh docker@$HOST "docker cp /home/docker/import.csv $(docker -H=tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}'):/var/lib/cassandra";
 i=$((i + 1));
 echo "done";
done 
# && \
#docker cp /home/docker/import $(docker -H=tcp://192.168.99.102:2376 ps | grep cassandra | awk '{print $1}'):/var/lib/cassandra/import.csv.gz"
}
#####

#####
# Function for copying data to the different Cassandra Nodes
###
copy_new() {
 i=1;
 for HOST in $NODES;
 do
  echo "Copying data to $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') on host $HOST ...";
  docker -H tcp://$HOST:2376 cp $HOME/projects/cassandra_cluster/testdata/import0$i.csv \
  $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}'):/var/lib/cassandra/import.csv;
  echo "done";
  echo "Importing data to Cassandra-DB in background ..."; 
  import &;
  i=$((i + 1));
 done 
}
#####

#####
# Funtion for importing Data into Cassandra-DB
###
import() {
 docker -H tcp://$HOST:2376 exec -ti $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') -c \
 "cqlsh COPY test.testdata (charge, clus, dst, hist, enumber, etime, rnumber, nlb, qxb, tracks, vertex, zdc) FROM '/var/lib/cassandra/xaa' WITH HEADER = FALSE" ;
}

# Calling the Functions
# unzip
copy_new