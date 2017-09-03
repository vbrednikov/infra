#!/bin/bash

# Local:
#  gcloud compute instances create --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20170815a --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone=europe-west1-b --metadata-from-file startup-script=start_all.sh reddit-app
# From github:
#  gcloud compute instances create --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20170815a --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone=europe-west1-b --metadata startup-script-url=https://github.com/vbrednikov/infra/start_all.sh



# Small optimization: add mongodb repo before all steps to run apt-get update once

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list && \
apt-get -y update && apt-get upgrade -y 
# install ruby for appuser
echo '--------- Install ruby -------------'
sudo -u "appuser" bash -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && curl -sSL https://get.rvm.io | bash -s stable && . ~/.rvm/scripts/rvm && rvm requirements && rvm install 2.4.1 && rvm use 2.4.1 --default && gem install bundler -V --no-ri --no-rdoc' 
# output ruby and bundler versions to syslog
sudo -u "appuser" bash -c '. ~/.rvm/scripts/rvm; echo -n Ruby version:\ ; ruby -v; echo -n Bundler: gem -v bundler'

echo '--------- Install mongodb ----------'
apt-get install -y mongodb-org && systemctl enable mongod && systemctl start mongod && systemctl status mongod

echo '--------- Deploy reddit app --------'
sudo -u "appuser" bash -c 'pushd ~ && . ~/.rvm/scripts/rvm && git clone https://github.com/Artemmkin/reddit.git && pushd reddit && bundle install && puma -d'
