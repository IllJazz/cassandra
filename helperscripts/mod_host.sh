HOST=$1

docker-machine stop $HOST 

if [ "$OSTYPE" = "msys" ]
then
# Windows
"/c/Program Files/Oracle/VirtualBox/VBoxManage" modifyvm $HOST --cpus 1 
"/c/Program Files/Oracle/VirtualBox/VBoxManage" modifyvm $HOST --memory 1024
else
# Linux
VBoxManage modifyvm $HOST --cpus 1
VBoxManage modifyvm $HOST --memory 1024
#
fi
#
docker-machine start $HOST