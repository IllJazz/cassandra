#!/bin/sh
#set -e
before=$(date +%s)
## DECLARATIONS ##
# get Worker-Nodes from Manager
#NODES=$(docker node inspect $(docker node ls -f "role=Worker" -q) --format '{{ .Status.Addr  }}')

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

#######################
# declare CQL Command # 
CQL="COPY test.test2 (uuid1, number1, uuid2, date1, number2, boo1, number3, number4, number5, number6, date2) \
FROM '/var/lib/cassandra/import.csv' WITH HEADER = FALSE AND MINBATCHSIZE = 2 AND MAXBATCHSIZE = 20 AND MAXROWS = 10000000 AND CHUNKSIZE=4800";
#######################
 
NUMBER_OF_HOSTS=$(echo $NODES | wc -w)
#FILENAME=$1
FILENAME=export_ilja_10.csv
ARCHIVENAME=$FILENAME".gz"

## FUNCTIONS ##

#####
# Function for unzipping and splitting the Data-File on Manager Node
###
unzip_archive() { 
 cd $HOME/projects/cassandra_cluster/testdata;
 "C:\Program Files\7-Zip\7z.exe" x $ARCHIVENAME;
 split --number=l/3 --numeric=1 --additional-suffix=".csv" $FILENAME "import";
 rm $FILENAME;
}
#####

#####
# Funktion for importing Data into Cassandra-DB
###
import() {
 HOST=$1;
  docker -H tcp://$HOST:2376 exec $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') cqlsh -e "$CQL" &
  PID
  echo "PID $!";
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
  import $HOST ;
  i=$((i + 1));
 done 
}
#####

#####
# standalone Funktion for testing importing Data into Cassandra-DB
###
import_test() {
 i=1;
 for HOST in $NODES;
 do
  docker -H tcp://$HOST:2376 exec $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') cqlsh -e "$CQL" ;
  i=$((i + 1));
 done 
}
 
importtest2() {
  HOST=$1;
  echo "Host: "$HOST;
  docker -H tcp://$HOST:2376 exec $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') cqlsh -e "$CQL" ;
}
##### 
 
#####
# Function for showing results - not used yet
show_results() {
 docker exec -ti $(docker ps | grep cassandra | awk '{print $1}') head -1 /var/lib/cassandra/import.csv
 docker exec -ti $(docker ps | grep cassandra | awk '{print $1}') cqlsh -e "select count(*) from test.test2; "
}

# Calling the Functions
unzip_archive
copy_new
#importtest2 "192.168.99.103"

wait $PID1
my_status=$?
echo "Exit Code $?"
wait $PID2
my_status=$?
echo "Exit Code $?"
wait $PID3
my_status=$?
echo "Exit Code $?"

after=$(date +%s)
echo "elapsed time:" $((after - $before)) "seconds"

