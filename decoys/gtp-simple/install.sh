#!/bin/bash
BASE="https://raw.githubusercontent.com/duijkere/dev/main/decoys/gtp-simple"

# create dir
sudo mkdir -p /opt/gtp-simple

# pull files
sudo curl -s $BASE/gtp_decoy.py -o /opt/gtp-simple/gtp_decoy.py
sudo curl -s $BASE/gtp-decoy.service -o /etc/systemd/system/gtp-decoy.service

# permissions
sudo chmod +x /opt/gtp-simple/gtp_decoy.py

# enable service
sudo systemctl daemon-reload
sudo systemctl enable gtp-decoy

echo "done - verify: systemctl status gtp-decoy"
