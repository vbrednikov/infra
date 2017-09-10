#!/bin/bash
set -e

source ~/.profile
if [[ -d ~/reddit ]] ; then 
    cd ~/reddit && git pull 
else 
    git clone https://github.com/Artemmkin/reddit.git
    cd reddit
    bundle install
fi

test -e /tmp/puma.service && sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo chown 0:0 /etc/systemd/system/puma.service
sudo chmod 644 /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
