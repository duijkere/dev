#!/bin/bash
BASE="https://raw.githubusercontent.com/duijkere/dev/main/decoys/open5gs"

sudo mkdir -p /opt/open5gs

sudo curl -s $BASE/open5gs-configure.sh -o /opt/open5gs/open5gs-configure.sh
sudo curl -s $BASE/open5gs-configure.service -o /etc/systemd/system/open5gs-configure.service

sudo chmod +x /opt/open5gs/open5gs-configure.sh

sudo systemctl daemon-reload
sudo systemctl enable open5gs-configure
sudo systemctl disable open5gs-upfd open5gs-smfd

logger -t open5gs-install "open5gs decoy install complete"
echo "done"
