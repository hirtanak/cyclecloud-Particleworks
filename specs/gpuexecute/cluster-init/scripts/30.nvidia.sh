#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
echo "starting 30.nvidia node set up"

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

# set up NVIDIA driver and compute nodes
CMD=$(cat /proc/driver/nvidia/version | head -1 | awk '{print $3}') | exit 0 
if [[ -z $CMD ]]; then
   echo "download and install NVIDIA Driver"
   yum install -y gcc dkms make kernel-devel-$(uname -r) kernel-headers-$(uname -r)  
   jetpack download cuda-repo-rhel7-9.1.85-1.x86_64.rpm ${HOMEDIR}/apps/
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/cuda-repo-rhel7-9.1.85-1.x86_64.rpm
   rpm -i ${HOMEDIR}/apps/cuda-repo-rhel7-9.1.85-1.x86_64.rpm
   yum clean all
   yum install -y cuda-9-1
else 
   echo "skipping install NVIDIA Driver"
fi

echo "ending 30.nvidia node set up"
