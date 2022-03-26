#!/bin/bash
source environment.sh
echo "Make sure the rootfs is set to full available size (when building on GCP)"
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda1
set -e
if [ ${use_gpu} == true ]; then
    # See https://cloud.google.com/compute/docs/gpus/install-drivers-gpu#no-secure-boot
    echo "Installing GPU drivers using Google Cloud method"
    curl https://raw.githubusercontent.com/GoogleCloudPlatform/compute-gpu-installation/main/linux/install_gpu_driver.py --output install_gpu_driver.py
    sudo python3 install_gpu_driver.py
fi
echo "Installing docker using https://docs.docker.com/engine/install/ubuntu/#installation-methods"
sudo apt-get update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Installing docker GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
set +e
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
set -e

echo "Installing additional docker dependencies"
sudo apt install qemu-user-static docker-compose

if [ ${use_gpu} == true ]; then
    echo "Installing nvidia-docker"
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
       && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
       && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

    sudo apt-get update
    sudo apt-get install -y nvidia-docker2
    sudo systemctl restart docker

    echo "Adding nvidia runtime default support"
    patchfile=$(mktemp)
    cat << EOF > ${patchfile}
--- old/daemon.json     2022-03-21 19:16:49.518033523 +0000
+++ new/daemon.json     2022-03-21 19:17:40.938411547 +0000
@@ -4,5 +4,6 @@
             "path": "nvidia-container-runtime",
             "runtimeArgs": []
         }
-    }
+    },
+    "default-runtime": "nvidia"
 }
EOF
    sudo patch -d /etc/docker -p1 < ${patchfile}
    rm ${patchfile}
    echo "Testing GPU access without specifying NVIDIA runtime"
    docker run --rm nvidia/cuda:11.0-base nvidia-smi   sudo systemctl restart docker
fi
echo "Installation complete, please install sighthound analytics service"
