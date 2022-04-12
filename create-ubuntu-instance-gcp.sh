#!/bin/bash
pushd $(dirname $0)
source environment.sh
if [ "${use_gpu}" = true ]; then
    machine_type="n1-standard-2"
    accelerator="--accelerator type=nvidia-tesla-t4,count=1"
else
    machine_type="c2d-standard-16"
fi
if [ -z "${project_id}" ]; then
    echo "You must define a project name"
    exit 1
fi
if [ -z "${compute_instance_name}" ]; then
    echo "You must define a compute instance name"
    exit 1
fi
if [ -z "${compute_instance_zone}" ]; then
    echo "You must define a compute instance zone"
    exit 1
fi
set -e
gcloud --project ${project_id} compute instances create ${compute_instance_name} \
        --machine-type ${machine_type} ${accelerator}\
        --zone ${compute_instance_zone} \
        --image-family ubuntu-2004-lts \
        --image-project ubuntu-os-cloud \
        --maintenance-policy TERMINATE --restart-on-failure
echo Resize the disk to use at least 100GB
gcloud --project ${project_id} compute disks resize --zone ${compute_instance_zone} ${compute_instance_name} --size=100GB
gcloud --project ${project_id} compute scp *.sh cust-device-key-config-*.json ${compute_instance_name}:~
echo "Instance created: Log into the device using \"gcloud --project ${project_id} compute ssh ${compute_instance_name}\" to complete the remainder of the instructions"
