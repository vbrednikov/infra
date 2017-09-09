#!/bin/bash
set -e

source ~/.profile
git clone https://github.com/Artemmkin/reddit.git
cd reddit
bundle install

sudo mv /tmp/puma.service /etc/systemd/system/puma.service
chown 0:0 /etc/systemd/system/puma.service
chmod 644 /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
