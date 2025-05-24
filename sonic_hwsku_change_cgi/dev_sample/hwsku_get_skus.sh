#!/usr/bin/bash 

#Usage: ./hwsku_get_skus.sh 10.111.60.15 admin Innovium123

IP=$1
USER=$2
PASSWD=$3

#/usr/bin/sshpass -p Innovium123 ssh  admin@10.111.60.15 ls /tmp
/usr/bin/sshpass -p $PASSWD scp hwsku_info.sh  $USER@$IP:/tmp/_g.sh
