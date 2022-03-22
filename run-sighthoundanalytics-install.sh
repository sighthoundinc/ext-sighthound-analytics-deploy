#!/bin/bash
set -e
install_wheel=shepherd-3.0.0rc1-py3-none-any.whl
sudo apt-get update && sudo apt-get -y install python3 python3-pip
wget https://storage.googleapis.com/ext-public-releases/${install_wheel}
sudo python3 -m pip install ${install_wheel}
sudo sighthound-analytics-install cust-device-key-config-*.json
