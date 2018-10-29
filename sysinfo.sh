#!/bin/bash

#Bash script to print Time, ip, etc. Was used in some server to print info  on user login

#Collect data


	function gather_info {
		date_=$(date +%d/%m/%Y)
		time_=$(date +%T)
		system_name=$(hostname --long)
		uptime=$(cut -d ' ' -f2 </proc/uptime)
		seconds=$((3600))
		runtime=$(bc -l <<<"scale=2; $uptime/$seconds")
		ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' |cut -f1 -d'/')
		os=$(grep 'PRETTY_NAME' /etc/*-release|cut -d\= -f2)
		dns_servers=$(cat /etc/resolv.conf|grep nameserver |cut -d' ' -f2|tr '\n' ','| sed 's/,$//')
		dns_name=$(cat /etc/resolv.conf|grep search |cut -d' ' -f2|tr '\n' ','| sed 's/,s$//')
		mem_usage=$(free -m | awk 'NR==2{printf "%sMB/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
		disk_use=$(df --total -h|grep '^total'|tr -s ' ' |awk '{print $3}')
		disk_total=$(df --total -h |grep '^total'|tr -s ' ' |awk '{print $2}')
		disk_percent=$(df --total -h |grep '^total'|tr -s ' '|awk '{print $5}')
		online_users=$(who -u |cut -d ' ' -f1 |sort | uniq|tr '\n' ',' | sed 's/,$//')
}
#Print data

	function print_info {
	echo "

 	System information

	Date: $date_ Time: $time_
	Server: $system_name
	Uptime: $runtime tuntia
	IP: $ip_addr
	Version: $os
	DNS: $dns_servers,$dns_name
	Memory: $mem_usage [ $time_ , $date_ ]
	Disk usage: ${disk_use}B / ${disk_total}B / ${disk_percent}
	Online: $online_users


 "

}



gather_info
print_info

