# Overview

This repository contains scripts to automate setup steps for Ubuntu deployed Sighthound Analytics instances.
It assumes execution on a WSL or Linux-like command line interface with support for bash scripts.  This includes
WSL Ubuntu on recent Windows releases.

# Google Cloud Platform deployment

This section describes deployment on Google Cloud Platform (GCP).  These instructions allow you to create
your own instance of the Sighthound Analytics deployment and potentially customize.

1. [Create a Project on Google Cloud Platform](https://developers.google.com/workspace/guides/create-project)
to hold the new instance.  You may also use an existing project, however you'll need to ensure your account
has Compute Instance Admin permissions for the project.

2. [setup gcloud CLI](https://cloud.google.com/sdk/gcloud) for your account.


3. Customize the `project_name` and `compute_instance_name` variables in the `environment.sh` script:
  * `project_name` should match the project you created in step 1.
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
