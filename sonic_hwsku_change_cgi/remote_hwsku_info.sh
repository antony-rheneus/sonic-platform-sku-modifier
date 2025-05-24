#!/bin/bash


. /etc/sonic/sonic-environment
#echo $PLATFORM 
#echo $HWSKU 
cd /usr/share/sonic/device/$PLATFORM/ 

declare -a hwsku=( )
cnt=0
for f in `find . -type d`; 
do 
	if [ ! -f $f/port_config.ini ]
	then
		continue
	fi
	cnt=$(($cnt + 1))
	hwsku[$cnt]=${f:2}
	echo ${f:2}
	#echo ${hwsku[$cnt]}
done

