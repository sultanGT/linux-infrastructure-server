#!/bin/bash
log_file="/home/sultan/linux-infrastructure-lab/logs/health-check.log"
exec > >(tee -a "$log_file") 2>&1
exit_code=0

server_name=$(hostname)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$timestamp]"
echo "Checking server: $server_name"



if systemctl  is-active --quiet nginx; then
	echo "[OK] Nginx is running"
else
	echo "[CRITICAL] Nginx is stopped"
	exit_code=2
fi

total_memory=$(free -m | awk '/^Mem:/ {print $2}')
available_memory=$(free -m | awk '/^Mem:/ {print $7}')
memory_percent=$(( (total_memory - available_memory) * 100 / total_memory  ))

if [ "$memory_percent" -ge 80 ]; then

	echo "[WARNING] Memory usage: $memory_percent%"

	if [ "$exit_code" -lt 1 ]; then
        	exit_code=1
    	fi
else
	echo "[OK] Memory usage: $memory_percent%"
fi

disk_percent=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

if [ "$disk_percent" -ge 80 ]; then
        echo "[WARNING] Disk usage: $disk_percent%"

	if [ "$exit_code" -lt 1 ]; then
                exit_code=1
        fi
else
        echo "[OK] Disk Usage: $disk_percent%"
fi

http_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)

if [ "$http_status" -eq 200 ]; then
        echo "[OK] Website responding HTTP $http_status"
else
        echo "[CRITICAL] Website issue: HTTP $http_status"
	exit_code=2
fi

exit "$exit_code"


