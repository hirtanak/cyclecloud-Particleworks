#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
echo "starting 30.nvidia node set up"
set -u

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
# After CycleCloud 7.9 and later 
if [[ -z $CUSER ]]; then
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
   CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /mnt/exports/shared/CUSER
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/Particleworks/gpuexecute

CUDA_VERSION=$(jetpack config CUDA_VERSION)

# set up NVIDIA driver and compute nodes
set +u
CMD=$(cat /proc/driver/nvidia/version | head -1 | awk '{print $3}') | exit 0 
if [[ -z $CMD ]]; then
   echo "download and install NVIDIA Driver"
   yum install -y gcc dkms make kernel-devel-$(uname -r) kernel-headers-$(uname -r)  
   jetpack download cuda-repo-rhel7-10-0-local-10.0.130-410.48-1.0-1.x86_64.rpm ${HOMEDIR}/apps/
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/cuda-repo-rhel7-10-0-local-${CUDA_VERSION}.130-410.48-1.0-1.x86_64.rpm
   rpm -i ${HOMEDIR}/apps/cuda-repo-rhel7-${CUDA_VERSION/./-}-local-${CUDA_VERSION}.130-410.48-1.0-1.x86_64.rpm
   yum clean all
   yum install -y cuda-${CUDA_VERSION/./-}
else 
   echo "skipping install NVIDIA Driver"
fi
set -u

echo "ending 30.nvidia node set up"
