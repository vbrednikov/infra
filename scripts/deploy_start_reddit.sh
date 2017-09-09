#!/bin/bash
echo '--------- Deploy reddit app --------'
sudo -u "appuser" bash -c 'pushd ~ && .  ~/.rvm/scripts/rvm && git clone https://github.com/Artemmkin/reddit.git && pushd reddit && bundle install && puma -d'
