#!/bin/bash
log_file="/home/sultan/linux-infrastructure-server/logs/health-check.log"
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

# Track the previous monitoring status
state_file="/home/sultan/linux-infrastructure-server/state/health-status"

# Read previous status, defaulting to HEALTHY
previous_status="HEALTHY"

if [ -f "$state_file" ]; then
    previous_status=$(cat "$state_file")
fi

# Determine current status
if [ "$exit_code" -eq 2 ]; then
    current_status="CRITICAL"
elif [ "$exit_code" -eq 1 ]; then
    current_status="WARNING"
else
    current_status="HEALTHY"
fi

# Only generate an alert when the status changes
if [ "$current_status" != "$previous_status" ]; then

    if [ "$current_status" = "CRITICAL" ]; then
        logger -p user.crit -t infrastructure-monitor \
        "CRITICAL: Infrastructure health check failed on $server_name"

    elif [ "$current_status" = "HEALTHY" ]; then
        logger -p user.notice -t infrastructure-monitor \
        "RECOVERY: Infrastructure is healthy again on $server_name"

    elif [ "$current_status" = "WARNING" ]; then
        logger -p user.warning -t infrastructure-monitor \
        "WARNING: Infrastructure health check detected an issue on $server_name"
    fi

fi

# Save current status for the next execution
echo "$current_status" > "$state_file"

exit "$exit_code"

exit "$exit_code"
