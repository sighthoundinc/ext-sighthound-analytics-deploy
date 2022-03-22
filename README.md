# Overview

This repository contains scripts to automate setup steps for Ubuntu deployed Sighthound Analytics instances

# GCP deployment

Customize the `project_name` and `compute_instance_name` variables in the `create-ubuntu-istance-gcp.sh` script.
Then run the script to create a GCP instance.
```
./create-ubuntu-instance-gcp.sh
```

Use the SSH command provided at the end of this script to SSH into the GCP instance.  Then run:
```
./run-ubuntu-install-base-nvidia-docker.sh
```
To setup a base install with nvidia-docker and components required for Sighthound analytics.

Finally, copy the provided `cust-device-key-config-*.json` file to this directory and run:
```
./run-sighthoundanalytics-install.sh
```
to complete the installation
