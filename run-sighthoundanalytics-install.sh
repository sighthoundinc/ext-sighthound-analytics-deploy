#!/bin/bash
set -e
source environment.sh
if [ -z "${install_wheel}" ]; then
    echo "Please set install wheel"
fi
key_config_file=$(ls cust-device-key-config-*.json)
if [ ! -f ${key_config_file} ]; then
    echo "Missing key config file"
fi
sudo apt-get update && sudo apt-get -y install python3 python3-pip
wget https://storage.googleapis.com/ext-public-releases/${install_wheel}
sudo python3 -m pip install ${install_wheel}
sudo sighthound-analytics-install ${key_config_file}
