#!/bin/bash

MONITORED_RESOURCE="$1"
TIMEOUT_MINUTES="$2"
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
LOG_FILE="/var/log/wireguard-monitor.log"

# Function to log messages with a timestamp
log() {
    echo "$(date +"%Y-%m-%d %T"): $1" >> "$LOG_FILE"
}

MONITORED_RESOURCE_DOWN=false
START_TIME=0

while true; do
    sleep 60

    if ping -c 1 -W 5 "$MONITORED_RESOURCE" > /dev/null 2>&1; then
        # Monitored resource is online
        if [ "$MONITORED_RESOURCE_DOWN" = true ]; then
            log "Monitored resource: $MONITORED_RESOURCE is back online."
            MONITORED_RESOURCE_DOWN=false
        fi
    else
        if [ "$MONITORED_RESOURCE_DOWN" = false ]; then
            log "Monitored resource: $MONITORED_RESOURCE is down. Initiating wg-quick@wg0.service restart... ${TIMEOUT_MINUTES}m timeout"
            MONITORED_RESOURCE_DOWN=true
            START_TIME=$(date +%s)
        fi
    fi

    # Check if timeout has been reached
    if [ "$MONITORED_RESOURCE_DOWN" = true ]; then
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ "$ELAPSED_TIME" -ge "$TIMEOUT_SECONDS" ]; then
            log "Timeout reached. Initiating wg-quick@wg0.service restart..."
            systemctl restart wg-quick@wg0.service
            log "wg-quick@wg0.service status: $(systemctl show -p ActiveState --value wg-quick@wg0.service)"
        fi
    fi
done
