#!/bin/bash
set -eu

#HOST IP
if [[ ! -v CASSANDRA_HOST_IP ]]; then
  #HOST_IP=nslookup localhost | grep '10.' | awk '{print $1}'
  HOST_IP=$(ping -c 1 cassandra | grep -ohE "\(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\)" | head -1 | sed "s/[()]//g")
  CASSANDRA_HOST_IP="${HOST_IP}"
else
  HOST_IP="${CASSANDRA_HOST_IP}"
fi

#PORT
if [[ ! -v CASSANDRA_PORT ]]; then
  CASSANDRA_PORT="9042"
else
  CASSANDRA_PORT="${CASSANDRA_PORT}"
fi

#USERNAME
if [[ ! -v CASSANDRA_USERNAME ]]; then
  CASSANDRA_USERNAME="cassandra"
else
  CASSANDRA_USERNAME="${CASSANDRA_USERNAME}"
fi

#PASSWORD
if [[ ! -v CASSANDRA_PASSOWRD ]]; then
  CASSANDRA_PASSOWRD="cassandra"
else
  CASSANDRA_PASSOWRD="${CASSANDRA_PASSOWRD}"
fi

COMMAND="cassandra-web --hosts $CASSANDRA_HOST_IP --port $CASSANDRA_PORT --username $CASSANDRA_USERNAME --password $CASSANDRA_PASSOWRD"

echo $COMMAND 

exec $COMMAND