#!/bin/bash

apt-get install nfs-common
apt-get install nfs-server
  
function shutdown {
    echo "Stopping NFS server ..."
    service nfs-kernel-server stop
    echo "NFS server stopped"
    exit 0
}

trap "shutdown" SIGTERM

mkdir -p /var/nfs/exports
chmod 777 /var/nfs/exports

echo "Starting NFS server ..."
rpcbind 
service nfs-kernel-server start
IP=`hostname -i`
echo "NFS server started and listening on $IP"

sleep infinity & wait

