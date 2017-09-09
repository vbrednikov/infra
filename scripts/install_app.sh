#!/usr/bin/env bash
set -e
echo '--------- Deploy reddit app --------'
which git || sudo apt-get install git -y
pushd ~ && .  ~/.rvm/scripts/rvm && git clone https://github.com/Artemmkin/reddit.git && pushd reddit && bundle install
