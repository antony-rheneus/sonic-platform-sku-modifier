#!/bin/bash


. /etc/sonic/sonic-environment
#echo $PLATFORM 
#echo $HWSKU 
cd /usr/share/sonic/device/$PLATFORM/ 

declare -a hwsku=( )

get_skus()
{
	cnt=0
	valid=0
	for f in `find . -type d`; 
	do 
		if [ ! -f $f/port_config.ini ]
		then
			continue
		fi
		cnt=$(($cnt + 1))
		hwsku[$cnt]=${f:2}

		#echo ${f:2}
		echo $cnt: ${hwsku[$cnt]}

		if [ ${hwsku[$cnt]} == $1 ]; then
			valid=1
		fi
	done
	if [ $valid -eq 0 ]; then
		echo "Invalid SKU $1"
		exit 2
	else
		echo "Found the SKU $1"
	fi
}

update_env()
{
	FNAME="/etc/sonic/sonic-environment"
	sudo sed -i "s/HWSKU=.*/HWSKU=$1/g" ${FNAME}
	echo "Updating Env From $HWSKU to $1"
}

update_config()
{
	FNAME="/etc/sonic/config_db.json"
	FPATH="/usr/share/sonic/device/$PLATFORM/$HWSKU/"
	echo "Taking backup $FNAME to $FPATH"
	sudo cp $FNAME $FPATH

	echo "Generating config files"
	sonic-cfggen -H -k $1 -p $1/port_config.ini --preset t1 > /tmp/m.json
	DVC_OPT=""
	if [ -f $FNAME ];then
		echo "{" > /tmp/d.json
	       	sed -n '/DEVICE_METADATA":/,/}/p' $FNAME >> /tmp/d.json
		echo "}}" >> /tmp/d.json
		DVC_OPT=" -j /tmp/d.json "
		echo "{" > /tmp/e.json
                sed -n '/MGMT_INTERFACE/,/}$/p' $FNAME >> /tmp/e.json
		echo "}}" >> /tmp/e.json
		lines=(`wc -l /tmp/e.json`)
		if [ ${lines[0]} -gt 2 ]; then
			DVC_OPT=${DVC_OPT}" -j /tmp/e.json "
		fi	
                hname=`jq '.DEVICE_METADATA.localhost.hostname' /etc/sonic/config_db.json`
                sed -i 's/"hostname": "sonic"/"hostname": "labaz01-ed0202"/g' /tmp/m.json
                jq '.DEVICE_METADATA.localhost.hostname = '"$hname"'' /tmp/m.json > /tmp/mh.json
		if [ $? -ne 0 ]; then
			echo "ERROR, generating configs"
			exit 5
		fi	
	else
		mv /tmp/m.json /tmp/mh.json
	fi
	sonic-cfggen -j /etc/sonic/init_cfg.json ${DVC_OPT} -j /tmp/mh.json  --print-data > /tmp/c.json
	if [ $? -ne 0 ]; then
		echo "ERROR, generating configs"
		exit 3
	fi	
	lines=(`wc -l /tmp/c.json`)
	if [ ${lines[0]} -lt 2 ]; then
		echo "ERROR, generating configs"
		exit 4
	fi	

	echo "Writing $FNAME"
	sudo cp /tmp/c.json $FNAME
	echo "Writing $FNAME to DB"
	sudo sonic-db-cli CONFIG_DB FLUSHDB
	sudo sonic-cfggen -j ${FNAME} --write-to-db
	sudo sonic-db-cli CONFIG_DB SET "CONFIG_DB_INITIALIZED" "1"
}

restart_docker()
{
	echo "Stopping Syncd docker"
	#Uncomment incase if syncd container has been updated/modified
	#sudo docker commit syncd
	#sudo docker image prune -f
	sudo docker stop syncd
	sudo docker rm syncd
	echo "Reloading configuration"
	#sudo config reload -y
	sudo reboot
}

usage_exit()
{
	echo "$0 <HwSKU name>"
	exit $1
}

main()
{
	if [ -z "$1" ];
	then
		echo "Error: usage"
		usage_exit 1
	fi

	get_skus $1

	update_config $1
	update_env $1
        restart_docker
}

main $@
