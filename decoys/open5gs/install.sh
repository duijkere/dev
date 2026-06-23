#!/bin/bash
BASE="https://raw.githubusercontent.com/duijkere/dev/main/decoys/open5gs"

mkdir -p /opt/open5gs

curl -s $BASE/open5gs-configure.sh -o /opt/open5gs/open5gs-configure.sh
curl -s $BASE/open5gs-configure.service -o /etc/systemd/system/open5gs-configure.service

chmod +x /opt/open5gs/open5gs-configure.sh

systemctl daemon-reload
systemctl enable open5gs-configure
systemctl disable open5gs-upfd open5gs-smfd

logger -t open5gs-install "open5gs decoy install complete"
echo "done"
