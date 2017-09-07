#!/usr/bin/env bash
set -e

echo '--------- Install mongodb ----------'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update && apt-get upgrade -y
apt-get install -y mongodb-org
systemctl enable mongod
systemctl start mongod
systemctl status mongod
