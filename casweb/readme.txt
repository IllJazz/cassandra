# with new image
docker run --net casnet --name casweb -d -p 3000:3000 192.168.99.100:5000/casweb:latest

# old way
docker run -d --net casnet --name casweb -e CASSANDRA_HOST_IP=${docker run -ti --net casnet alpine sh -c "nslookup cassandra localhost | grep ': 10.' | awk '{print $3}'"} -e CASSANDRA_PORT=9042 -p 3000:3000 192.168.99.100:5000/casweb