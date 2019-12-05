#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak

echo "starting 10.cpuexecute node set up"

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
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/Particleworks/cpuexecute

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
(echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:/shared/home/azureuser/apps/pw-linux-package/module"; echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOMEDIR}/apps/pw-linux-package/module") > /etc/profile.d/pw.sh
chmod +x /etc/profile.d/pw.sh
chown ${CUSER}:${CUSER} /etc/profile.d/pw.sh
CMD2=$(grep PARTICLE_LICENSE_FILE ${HOMEDIR}/.bashrc) | exit 0 
set +u
if [[ -z "${CMD2}" ]]; then
   (echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:/shared/home/azureuser/apps/pw-linux-package/module"; echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOMEDIR}/apps/pw-linux-package/module") >> ${HOMEDIR}/.bashrc
fi
set -u

# packages
yum install -y htop

## H16r or H16r_Promo
if [[ $VMSKU = E5-2667 ]]; then
  if [[ -d /opt/intel ]]; then
    echo "Proccesing H16r or already installed"
  else 
    yum install -f redhat-lsb-core
    echo "Proccesing H16r_Promo"
    if [[ ! -f ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}.tgz ]]; then
      wget -nv https://hirostpublicshare.blob.core.windows.net/solvers/l_mpi_p_${IMPI_VERSION}.tgz -O ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}.tgz
      chown ${CUSER}:${CUSER} ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}.tgz
    fi
    tar zxfp ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}.tgz -C ${HOMEDIR}
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}
    sed -i -e 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/' ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}/silent.cfg
    sed -i -e 's/ACTIVATION_TYPE=exist_lic/ACTIVATION_TYPE=trial_lic/' ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}/silent.cfg
    ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}/install.sh -s ${HOMEDIR}/l_mpi_p_${IMPI_VERSION}/silent.cfg --ignore-signature --ignore-cpu
  fi
    chmod -R a+rx /opt/intel 
    chown -R ${CUSER}:${CUSER} /opt/intel
fi

## HC/HB set up
if [[ ${CORES} = 44 ]] ; then
  echo "Proccesing HC44rs"
  grep "vm.zone_reclaim_mode = 1" /etc/sysctl.conf || echo "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf sysctl -p
  # resource unlimit setting
  CMD1=$(tail -1 /etc/security/limits.conf)
  if [[ $CMD1 != '* soft nofile 65535' ]]; then
    (echo "* hard memlock unlimited"; echo "* soft memlock unlimited"; echo "* hard nofile 65535"; echo "* soft nofile 65535") >> /etc/security/limits.conf
  fi
fi

if [[ ${CORES} = 60 ]] ; then
  echo "Proccesing HB60rs"
  grep "vm.zone_reclaim_mode = 1" /etc/sysctl.conf || echo "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf sysctl -p
  # resource unlimit setting
  CMD1=$(tail -1 /etc/security/limits.conf)
  if [[ $CMD1 != '* soft nofile 65535' ]]; then
    (echo "* hard memlock unlimited"; echo "* soft memlock unlimited"; echo "* hard nofile 65535"; echo "* soft nofile 65535") >> /etc/security/limits.conf
  fi
fi

echo "ending 10.cpuexecute node set up"
