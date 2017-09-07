#!/usr/bin/env bash
set -e
echo '--------- Install ruby and rvm ------'
# install ruby for appuser
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
. ~/.rvm/scripts/rvm
rvm requirements
rvm install 2.4.1
rvm use 2.4.1 --default
gem install bundler -V --no-ri --no-rdoc
# output ruby and bundler versions to syslog
echo -n Ruby version:\ ; ruby -v
echo -n Bundler version:\ ; gem -v bundler
