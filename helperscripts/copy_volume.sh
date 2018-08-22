#!/bin/sh
# Script for copying Datavolumes from one host to another
SOURCE_DATA_VOLUME_NAME=$1
SOURCE_HOST="docker@"$2
TARGET_HOST="docker@"$3
# source = target
TARGET_DATA_VOLUME_NAME=$SOURCE_DATA_VOLUME_NAME

#First check if the user provided all needed arguments
if [ "$1" = "" ]
then
        echo "Please provide a source volume name"
        exit
fi

if [ "$2" = "" ] 
then
        echo "Please provide a destination volume name"
        exit
fi

#Check if the source volume name does exist
ssh $SOURCE_HOST 'docker volume inspect $SOURCE_DATA_VOLUME_NAME' > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source volume \"$SOURCE_DATA_VOLUME_NAME\" does not exist"
        exit
fi

#Now check if the destinatin volume name does not yet exist
ssh $TARGET_HOST 'docker volume inspect $TARGET_DATA_VOLUME_NAME' > /dev/null 2>&1

if [ "$?" = "0" ]
then
        echo "The destination volume \"$TARGET_DATA_VOLUME_NAME\" already exists"
        exit
fi

echo "Creating destination volume \"$TARGET_DATA_VOLUME_NAME\"..."
ssh $SOURCE_HOST 'docker volume create --name $TARGET_DATA_VOLUME_NAME'  
echo "Copying data from source volume \"$SOURCE_DATA_VOLUME_NAME\" to destination volume \"$TARGET_DATA_VOLUME_NAME\"..."
ssh $SOURCE_HOST 'docker run --rm -it -v $SOURCE_DATA_VOLUME_NAME:/from \
alpine ash -c "cd /from ; tar -cf - . " ' | \
ssh $TARGET_HOST 'docker run --rm -i -v $TARGET_DATA_VOLUME_NAME:/to \
alpine ash -c "cd /to ; tar -xpvf - " '


#docker run --rm -v SOURCE_DATA_VOLUME_NAME:/from alpine ash -c "cd /from ; tar -cf - . " | ssh TARGET_HOST 'docker run --rm -i -v TARGET_DATA_VOLUME_NAME:/to alpine ash -c "cd /to ; tar -xpvf - " '
#docker run --rm -v casdata:/from alpine ash -c "cd /from ; tar -cf - . " | ssh docker@192.168.99.103 'docker run --rm -i -v casdata:/to alpine ash -c "cd /to ; tar -xpvf - " '