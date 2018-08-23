# how to replace a node
# tar cassandra host data
docker run -ti --name copy -v casdata:/tmp alpine sh -c "cd /tmp; tar -cf data.tar ."
# copy tar from old cassandra host and remove container
docker cp copy:/tmp/data.tar . && docker rm copy
# move data from old host to new host
scp data.tar docker@192.168.99.103:/home/docker/data.tar && rm data.tar
# create volume
docker create volume casdata
# untar data to volume
docker run --rm -it -v casdata:/to -v /home/docker:/from alpine sh -c "cd /to ; tar -xpvf /from/data.tar"
# start cassandra (node join)
# remove old node or replace?

