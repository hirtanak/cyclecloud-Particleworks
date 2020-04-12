#!/usr/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 10.master.sh"

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

# For cyclecoud 7.8.x
CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
if [ -z "$CUSER" ]; then
  # For cyclecloud 7.9.x
  CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}')
  CUSER=${CUSER//\'/}
  CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /mnt/exports/CUSER
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/Particleworks/master

# get file name
PWFILENAME=$(jetpack config PWFileName)
# set PW version
PW_VERSION=$(echo $PWFILENAME | awk '{print $2}')

if [[ "`echo ${PW_PLATFORM} | grep platform_mpi`" ]] ; then
  MPI_PLATFORM=platform_mpi
else
  MPI_PLATFORM=intel_mpi
fi

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# resource ulimit setting
CMD1=$(grep memlock ${HOMEDIR}/.bashrc | head -2)
if [[ -z "${CMD1}" ]]; then
   (echo "ulimit -m unlimited") >> ${HOMEDIR}/.bashrc
fi

# License Port Setting
set +u
LICENSE=$(jetpack config LICENSE)
(echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:${HOMEDIR}/apps/pw-linux-package/module:/opt/pbs/bin"; echo "export LD_LIBRARY_PATH=${HOMEDIR}/apps/pw-linux-package/module") > /etc/profile.d/pw.sh
chmod +x /etc/profile.d/pw.sh
chown ${CUSER}:${CUSER} /etc/profile.d/pw.sh
CMD2=$(grep PARTICLE_LICENSE_FILE ${HOMEDIR}/.bashrc | head -1) | exit 0 
if [[ -z "${CMD2}" ]]; then
   (echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:${HOMEDIR}/apps/pw-linux-package/module"; echo "export LD_LIBRARY_PATH=${HOMEDIR}/apps/pw-linux-package/module") >> ${HOMEDIR}/.bashrc
fi
set -u

# packages
yum install -y htop

# Create Application Dirctory
if [ ! -d ${HOMEDIR}/apps ]; then
   sudo -u ${CUSER} ln -s /mnt/exports/apps ${HOMEDIR}/apps
   chown ${CUSER}:${CUSER} /mnt/exports/apps
fi
chown ${CUSER}:${CUSER} /mnt/exports/apps | exit 0


# Installation
if [ ! -d ${HOMEDIR}/apps/pw-linux-package ]; then
   jetpack download "${PWFILENAME}" ${HOMEDIR}/apps
fi
chown ${CUSER}:${CUSER} "${HOMEDIR}/apps/${PWFILENAME}"
unzip -o -q "${HOMEDIR}/apps/${PWFILENAME}" -d ${HOMEDIR}/apps 
# chown -R ${CUSER}:${CUSER} "${HOMEDIR}/apps/${PWFILENAME}"
unzip -o -q "${HOMEDIR}/apps/${PWFILENAME%.zip}/Install/pw-${PW_VERSION}_linux_64.zip" -d ${HOMEDIR}/apps
chown -R ${CUSER}:${CUSER} "${HOMEDIR}/apps/${PWFILENAME}"
chown -R ${CUSER}:${CUSER} "${HOMEDIR}/apps/pw-linux-package"

# set up user files
if [ ! -f ${HOMEDIR}/pwsetup.sh ]; then
   cp ${CYCLECLOUD_SPEC_PATH}/files/pwsetup.sh ${HOMEDIR} 
fi
chmod a+rx ${HOMEDIR}/pwsetup.sh
chown ${CUSER}:${CUSER} ${HOMEDIR}/pwsetup.sh

if [ ! -f ${HOMEDIR}/pwrun.sh ]; then
#   cp ${CYCLECLOUD_SPEC_PATH}/files/pwrun.sh ${HOMEDIR}
   : 
fi
#chmod a+rx ${HOMEDIR}/pwrun.sh
#chown ${CUSER}:${CUSER} ${HOMEDIR}/pwrun.sh

#clean up
popd
rm -rf $tmpdir

echo "end of 10.master.sh"
