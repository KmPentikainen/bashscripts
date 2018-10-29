#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:



TMP_FILE="/tmp/pingtest.tmp"

if [ -r $TMP_FILE ]; then
	FAILS=`cat $TMP_FILE`
else

	FAILS=0
fi
EMAIL="mymail@example.com"

SERVER="example.com"


ping -c 1 $SERVER >/dev/null 2>&1
if [ $? -ne 0 ]; then
	FAILS=$[FAILS + 1 ]
else
	FAILS=0
fi
if [ $FAILS -gt 4 ]; then
	FAILS=0
	echo "Cant connect to  $SERVER " \
	| mail -s "$SERVER down!" "$EMAIL" 
 fi
echo $FAILS > $TMP_FILE 
