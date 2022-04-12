# Overview

This repository contains scripts to automate setup steps for Ubuntu deployed Sighthound Analytics instances.
It assumes execution on a WSL or Linux-like command line interface with support for bash scripts.  This includes
WSL Ubuntu on recent Windows releases.

# Deployments

## Google Cloud Platform deployment

This section describes deployment on Google Cloud Platform (GCP).  These instructions allow you to create
your own instance of the Sighthound Analytics deployment and potentially customize.

1. [Create a Project on Google Cloud Platform](https://developers.google.com/workspace/guides/create-project)
to hold the new instance.  You may also use an existing project, however you'll need to ensure your account
has Compute Instance Admin permissions for the project.

2. [Setup gcloud CLI](https://cloud.google.com/sdk/gcloud) for your account and host system.

3. Customize the `project_id` and `compute_instance_name` variables in the `environment.sh` script:
  * `project_id` should match the project ID (not name) you created in step 1.
  * `compute_instance_name` should be the name of the instance you'd like to create.  This can be anything
you choose, subject to GCP [naming requirements](https://cloud.google.com/compute/docs/naming-resources).
  * `use_gpu` can be set to `true` to use a GPU deployment.  Refer to Google Cloud [GPU Pricing Detail](https://cloud.google.com/compute/gpus-pricing) for details about cost.

4. Obtain a key package from Sighthound which enables your deployment, and copy this key package
into the directory where you've checked out this repository.

5. Run this script to create the instance in your specified project:
```
./create-ubuntu-instance-gcp.sh
```
This script will create the instance in the specified project and copy in content.  It will
provide a `gcloud compute ssh` command you can use to ssh into the instance for further configuration.

6.  Use the SSH command provided at the end of the previous script to SSH into the GCP instance.  Then run:
```
./run-ubuntu-install-base-nvidia-docker.sh
```
To setup a base install with nvidia-docker and components required for Sighthound analytics.

7. While ssh'd into the GCP instance, use the script
```
./run-sighthoundanalytics-install.sh
```
to complete the installation of sighthound analytics.

### Port Forward Into Instance

You can forward ports from your GCP instance to localhost, then access the Analytics Webapp at http://localhost:8081.  Use a command like one below, where
the `environment.sh` contains variables setup in step 1
```
source environment.sh
gcloud --project ${project_id} compute ssh --ssh-flag="-L 4000:localhost:4000 -L 8081:localhost:81 -L 15674:localhost:15674 -L 8085:localhost:8085"  ${compute_instance_name}
```

## Custom Hardware

You may also deploy your own instance using a custom hardware platform.

### Requirements
* [Ubuntu 20.04](https://releases.ubuntu.com/20.04/) installation.
* Your machine should contain:
  * A recent (<5 years old) Intel or AMD CPU
    * At least 8 GB RAM (roughly 4GB per video stream)
  * Optionally (for best performance), An Nvidia GPU from the 1000, 2000, or 3000 series with:
    * CUDA >= 11.3
    * TensorRT 8.0 and CUDNN 8.2 available via NVIDIA runtime

### Set Up Docker
Follow the instructions here: [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

Additionally, install docker compose:
```
sudo apt install qemu-user-static docker-compose
```

### Set Up Python
```
sudo apt-get update && sudo apt-get -y install python3 python3-pip
```
### Set Up Cuda/Nvidia Runtime

These instructions are only necessary when using an NVIDIA GPU.

1. Follow instructions here: [CUDA Toolkit 11.6 Update 1 Downloads](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_network)
2. Next, install the cuda container toolkit here: [Welcome — NVIDIA Cloud Native Technologies  documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit)
3.  Configure the default runtime by editing `/etc/docker/daemon.json` and adding "default-runtime": "nvidia", e.g.
```
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```
4. Reboot your machine after installing all of these packages.

You can test that the docker runtime is functioning correctly with `docker run --rm nvidia/cuda:11.0-base nvidia-smi`

### Installing Sighthound Analtyics

1. Add your key package to the directory containing the [run-sighthoundanalytics-install.sh](run-sighthoundanalytics-install.sh) script.
2. Run `./run-sighthoundanalytics-install.sh`

### Upgrading Sighthound Analtyics

Repeat the installation steps above.

