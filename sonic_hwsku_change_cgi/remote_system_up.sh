#!/bin/bash


cnt=0;
until nc -vzw 2 $1 22 >/dev/null 2>&1 ; 
do 
	cnt=$((cnt+1)); 
	if [ $cnt -eq 20 ]; 
	then 
		echo "Waiting for $1 : $cnt"
		break; 
	fi ; 
done

echo "$1 is Up"
