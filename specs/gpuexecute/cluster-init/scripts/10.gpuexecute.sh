#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -x
echo "starting 10.gpuexecute node set up"

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
# After CycleCloud 7.9 and later 
if [[ -z $CUSER ]]; then
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
   CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /mnt/exports/CUSER
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/Particleworks/gpuexecute

# MPI version
IMPI_VERSION=5.1.3.223

echo "disabling selinux"
sudo setenforce 0
sudo sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

# license port setting
LICENSE=$(jetpack config LICENSE)
(echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:${HOMEDIR}/apps/pw-linux-package/module:/usr/local/cuda-9.1/bin"; echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOMEDIR}/apps/pw-linux-package/module:/usr/local/cuda/lib64") > /etc/profile.d/pw.sh
chmod +x /etc/profile.d/pw.sh
chown ${CUSER}:${CUSER} /etc/profile.d/pw.sh

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# Azure VMs that have ephemeral storage mounted at /mnt/exports.
if [ ! -d ${HOMEDIR}/apps ]; then
   sudo -u ${CUSER} ln -s /mnt/exports/apps ${HOMEDIR}/apps
   chown ${CUSER}:${CUSER} /mnt/exports/apps
fi
chown ${CUSER}:${CUSER} /mnt/exports/apps | exit 0

# packages
yum install -y htop


echo "ending 10.gpuexecute node set up"
