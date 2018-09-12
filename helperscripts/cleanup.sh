HOST=$1
KEYSPACE=$2
TABLE=$3
winpty docker -H=tcp://$HOST:2376 exec -ti \
  $(docker -H tcp://$HOST:2376 ps | grep cassandra | awk '{print $1}') \
  nodetool cleanup