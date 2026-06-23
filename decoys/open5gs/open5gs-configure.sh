#!/bin/bash
# get decoy IP at boot
DECOY_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')

# patch UPF - replace 127.0.0.7 with decoy IP
sed -i "s/address: 127.0.0.7/address: $DECOY_IP/g" /etc/open5gs/upf.yaml

# patch SMF gtpc and gtpu - replace 127.0.0.4 with decoy IP
# but keep pfcp client pointing to UPF internally
sed -i "/gtpc:/,/server:/{s/address: 127.0.0.4/address: $DECOY_IP/g}" /etc/open5gs/smf.yaml
sed -i "/gtpu:/,/server:/{s/address: 127.0.0.4/address: $DECOY_IP/g}" /etc/open5gs/smf.yaml

# log to syslog
logger -t open5gs-configure "configured open5gs with decoy IP: $DECOY_IP"

# restart services
systemctl restart open5gs-upfd
systemctl restart open5gs-smfd
