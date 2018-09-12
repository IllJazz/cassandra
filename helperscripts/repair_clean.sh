# repair (full) and clean when new nodes are added
# updating data between nodes
docker .. nodetool repair
# freeing diskspace
docker .. nodetool cleanup