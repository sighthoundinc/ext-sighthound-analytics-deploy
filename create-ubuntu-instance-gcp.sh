# Enter a project here corresponding to your gcloud project name
project_name=
# Add a name matching the instance you'd like to create for your compute node
compute_instance_name=
# Add the zone here for google cloud compute zones
compute_instance_zone=us-central1-a
use_gpu=false
if [ "${use_gpu}" = true ]; then
    machine_type="n1-standard-2"
    accellerator="--accelerator type=nvidia-tesla-t4,count=1"
else
    machine_type="c2d-standard-16"
fi
if [ -z "${project_name}" ]; then
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
gcloud --project ${project_name} compute instances create ${compute_instance_name} \
        --machine-type ${machine_type} ${accelerator}\
        --zone ${compute_instance_zone} \
        --image-family ubuntu-2004-lts \
        --image-project ubuntu-os-cloud \
        --maintenance-policy TERMINATE --restart-on-failure
# Resize the disk to use at least 100GB
gcloud --project ${project_name} compute disks resize --zone ${compute_instance_zone} ${compute_instance_name} --size=100GB
echo "Instance created: Log into the device using \"gcloud --project ${project_name} compute ssh ${compute_instance_name}\" to complete the remainder of the instructions"
