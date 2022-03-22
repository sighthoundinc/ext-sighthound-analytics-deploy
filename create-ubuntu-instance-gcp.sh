# Enter a project here corresponding to your gcloud project name
project_name=enter-your-name-here
# Add a name matching the instance you'd like to create for your compute node
compute_instance_name=sighthound-analytics
# Add the zone here for google cloud compute zones
compute_instance_zone=us-central1-a
set -e
gcloud compute instances create ${compute_instance_name} \
    --machine-type n1-standard-2 \
    --zone ${compute_instance_zone} \
    --accelerator type=nvidia-tesla-t4,count=1 \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --maintenance-policy TERMINATE --restart-on-failure
# Resize the disk to use at least 100GB
gcloud compute disks resize --zone ${compute_instance_zone} ${compute_instance_name} --size=100GB

echo "Instance created: Log into the device using \"gcloud compute ssh ${compute_instance_name}\" to complete the remainder of the instructions"