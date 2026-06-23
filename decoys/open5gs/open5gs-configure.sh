#!/bin/bash

# guard - only run at deployment, not during build
# build VM uses 10.254.x.x range assigned by FDC during customization
CURRENT_IP=$(ip addr show | grep 'inet ' | grep -v '127\.' | awk '{print $2}' | cut -d'/' -f1 | head -1)

if [[ $CURRENT_IP == 10.254.* ]]; then
    logger -t open5gs-configure "build phase detected ($CURRENT_IP), skipping configuration"
    exit 0
fi

# get decoy deployment IP
DECOY_IP=$CURRENT_IP

if [ -z "$DECOY_IP" ]; then
    logger -t open5gs-configure "ERROR: could not detect IP"
    exit 1
fi

logger -t open5gs-configure "deployment phase detected, configuring with IP: $DECOY_IP"

# patch only active (uncommented) address lines
sudo sed -i "/^[^#]/s/address: 127.0.0.7/address: $DECOY_IP/" /etc/open5gs/upf.yaml
sudo sed -i "/^[^#]/s/address: 127.0.0.4/address: $DECOY_IP/" /etc/open5gs/smf.yaml

logger -t open5gs-configure "yamls patched, starting services"

systemctl start open5gs-upfd
systemctl start open5gs-smfd

logger -t open5gs-configure "done"
