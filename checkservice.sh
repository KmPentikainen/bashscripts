#!/bin/bash
#check if service is running, if not start it

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

service=mysql

if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0))
then
echo "$service is running"
else
/etc/init.d/$service start
fi
