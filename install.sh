#!/bin/bash

# Destination directory for scripts
DEST_DIR="/usr/local/bin"
# Destination directory for service files
SERVICE_DIR="/etc/systemd/system"
# Destination directory for env files
ENV_DIR="/etc/default"
# Log file directory
LOG_DIR="/var/log"

MONITORED_RESOURCE="$1"
TIMEOUT_MINUTES="$2"


# Check for existing service name
existing_service=$(systemctl list-units --full --no-legend --plain --all --type=service --state=active --state=inactive | grep -oP "^(wireguard-monitor\.service)" | head -n1)

if [ -n "$existing_service" ]; then
    # Stop and disable existing service
    systemctl stop "$existing_service"
    systemctl disable "$existing_service"
    rm -rf $SERVICE_DIR/wireguard-monitor*
    rm -rf $DEST_DIR/wireguard-monitor.sh
    rm -rf $ENV_DIR/wireguard-monitor
fi

# Copy monitoring script to destination directory
cp wireguard-monitor.sh $DEST_DIR
chmod +x $DEST_DIR/wireguard-monitor.sh

# Create systemd service file for monitoring
cp wireguard-monitor.service $SERVICE_DIR/

# Create env file
touch $ENV_DIR/wireguard-monitor
chmod 644 $ENV_DIR/wireguard-monitor
cat <<EOF > "${ENV_DIR}/wireguard-monitor"
MONITORED_RESOURCE=$MONITORED_RESOURCE
TIMEOUT_MINUTES=$TIMEOUT_MINUTES
EOF

# Create log file
touch $LOG_DIR/wireguard-monitor.log
chmod 644 $LOG_DIR/wireguard-monitor.log

# Enable and start the monitoring service
systemctl enable wireguard-monitor.service
systemctl start wireguard-monitor.service

echo "Installation completed."

