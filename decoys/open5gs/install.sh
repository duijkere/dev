#!/bin/bash
BASE="https://raw.githubusercontent.com/duijkere/dev/main/decoys/open5gs"

# create ssh user for debugging
sudo useradd -m -s /bin/bash seadmin
echo "seadmin:SecOps2026!" | sudo chpasswd
sudo usermod -aG sudo seadmin
sudo systemctl enable ssh

# install open5gs configure
sudo mkdir -p /opt/open5gs
sudo curl -s $BASE/open5gs-configure.sh -o /opt/open5gs/open5gs-configure.sh
sudo curl -s $BASE/open5gs-configure.service -o /etc/systemd/system/open5gs-configure.service
sudo chmod +x /opt/open5gs/open5gs-configure.sh
sudo systemctl daemon-reload
sudo systemctl enable open5gs-configure
sudo systemctl disable open5gs-upfd open5gs-smfd

logger -t open5gs-install "install complete"
echo "done"
