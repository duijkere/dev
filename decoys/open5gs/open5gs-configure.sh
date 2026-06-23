#!/bin/bash

# get decoy IP - try multiple methods
DECOY_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}')

# fallback - get first non-loopback interface IP
if [ -z "$DECOY_IP" ]; then
    DECOY_IP=$(ip addr show | grep 'inet ' | grep -v '127\.' | awk '{print $2}' | cut -d'/' -f1 | head -1)
fi

# log what we got
logger -t open5gs-configure "detected decoy IP: $DECOY_IP"

if [ -z "$DECOY_IP" ]; then
    logger -t open5gs-configure "ERROR: could not detect IP, aborting"
    exit 1
fi

# patch UPF
sed -i "s/address: 127.0.0.7/address: $DECOY_IP/g" /etc/open5gs/upf.yaml

# patch SMF
sed -i "s/address: 127.0.0.4/address: $DECOY_IP/g" /etc/open5gs/smf.yaml

logger -t open5gs-configure "patched yamls with IP: $DECOY_IP"

# start services
systemctl start open5gs-upfd
systemctl start open5gs-smfd

logger -t open5gs-configure "services started"
