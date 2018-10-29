#!/bin/bash

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:
EMAIL="example@example.com"
function sysstat {
echo -e "
****************************************************

			Information
****************************************************

Hostname: `hostname`
Kernel Version: `uname -r`
Uptime: `uptime | sed 's/.*up\([^,]*\),.*/\1/'`
Latest boot: `who -b | awk '{print $3,$4}'`

******************************************************

			CPU Load

 	

*******************************************************
"
MPSTAT=`which mpstat`
MPSTAT=$?
if [ $MPSTAT != 0 ]
 then

	echo"MPSTAT is not available"

else

echo -e ""
LSCPU=`which lscpu`
LSCPU=$?
if [ $LSCPU != 0 ]
 then

	RESULT=$RESULT"PLACEHOLDER"
else
cpus=`lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}'`
i=0
while [ $i -lt $cpus ]
do


	echo "CPU$i : `mpstat -P ALL | awk -v var=$i '{ if ($3 == var ) print $4 }' `"

	let i=$i+1
done
fi
echo -e "
Load Average : `uptime | awk -F'load average:' ' { print $2 }' | cut -f1 -d,`

Health Status : `uptime | awk -F'load average:' ' { print $2 }' | cut -f1 -d, | awk '{if ($1 > 2) print "EI HYVÄ"; else if ($1 > 1 ) print "WAAARNIIING"; else print "OK"}'`
"
fi
echo -e "
*********************************************************

			Processes

*********************************************************

=> Processes that consume memory

PID %MEM RSS COMMAND
`ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10`

=> Processes that consume CPU
`top b -n1 | head -17 | tail -11`


********************************************************

			Disk Usage

********************************************************
"
df -Pkh | grep -v 'Filesystem' > /tmp/df.status
while read DISK
do

	LINE=`echo $DISK | awk '{print $1,"\t",$6,"\t",$5," used","\t",$4," free space"}'`
	echo -e $LINE
	echo
done < /tmp/df.status
echo -e "DISK STATUS"
echo
while read DISK
do
	USAGE=`echo $DISK | awk '{print $5}' | cut -f1 -d%`
	if [ $USAGE -ge 95 ]
	then
		STATUS='Not Good'
	elif [ $USAGE -ge 90 ]
	then
		STATUS='Runnong out of space'
	else
		STATUS='OK'
	fi

	LINE=`echo $DISK | awk '{print $1,"\t",$6}'`
		echo -ne $LINE "\t\t" $STATUS
	echo
done < /tmp/df.status
rm /tmp/df.status
TOTALMEM=`free -m | head -2 | tail -1 | awk '{print $2}'`
TOTALBC=`echo "scale=2;if($TOTALMEM<1024 && $TOTALMEM > 0) print 0;$TOTALMEM/1024" | bc -l`
USEDMEM=`free -m | head -2 | tail -1 | awk '{print $3}'`
USEDBC=`echo "scale=2;if($USEDMEM<1024 && $USEDMEM > 0) print 0;$USEDMEM/1024" | bc -l`
FREEMEM=`free -m | head -2 | tail -1 | awk '{print $4}'`
FREEBC=`echo "scale=2;if($FREEMEM<1024 && $FREEMEM > 0) print 0;$FREEMEM/1024" | bc -l`
TOTALSWAP=`free -m | tail -1 | awk '{print $2}'`
TOTALSBC=`echo "scale=2;if($TOTALSWAP<1024 && $TOTALSWAP > 0) print 0;$TOTALSWAP/1024" | bc -l`
USEDSWAP=`free -m | tail -1 | awk '{print $3}'`
USEDSBC=`echo "scale=2;if($USEDSWAP<1024 && $USEDSWAP > 0) print 0;$USEDSWAP/1024" | bc -l`
FREESWAP=`free -m | tail -1 | awk '{print $4}'`
FREESBC=`echo "scale=2;if($FREESWAP<1024 && $FREESWAP > 0) print 0;$FREESWAP/1024" | bc -l`

echo -e "
*********************************************************

			Memory

*********************************************************

=> Physical memory

Total\tUsed\tFree\t%Free

${TOTALBC}GB\t${USEDBC}GB \t${FREEBC}GB\t$(($FREEMEM * 100 / $TOTALMEM ))%

=> Swap Memory

Total\tUsed\tFree\t%Free

${TOTALSBC}GB\t${USEDBC}GB \t${FREESBC}GB\t$(($FREESWAP * 100 / $TOTALSWAP ))%
"
}
cd /home/user/reports/healthreports
FILENAME="health-`hostname`-`date +%y%m%d`-`date +%H%M`.txt"
sysstat > $FILENAME
echo "File $FILENAME created /home/user/reports/healthreports." $RESULT

cat $FILENAME | mailx -s "Healthreport" example@example.com
