#!/usr/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 10.install_pw.sh"

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
echo ${CUSER} > /mnt/exports/shared/CUSER
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
CMD1=$(grep ulimit ${HOMEDIR}/.bashrc | head -2)
if [[ -z "${CMD1}" ]]; then
   (echo "ulimit -m unlimited") >> ${HOMEDIR}/.bashrc
fi

# License Port Setting
LICENSE=$(jetpack config LICENSE)
set +u
(echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:/opt/pbs/bin:/shared/home/azureuser/apps/pw-linux-package/module"; echo "export LD_LIBRARY_PATH=${HOMEDIR}/apps/pw-linux-package/module"; echo "export DISPLAY=localhost:0.0") > /etc/profile.d/pw.sh
chmod +x /etc/profile.d/pw.sh
chown ${CUSER}:${CUSER} /etc/profile.d/pw.sh
CMD2=$(grep PARTICLE_LICENSE_FILE ${HOMEDIR}/.bashrc) | exit 0 
if [[ -z "${CMD2}" ]]; then
   (echo "export PARTICLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:/opt/pbs/bin:/shared/home/azureuser/apps/pw-linux-package/module"; echo "export LD_LIBRARY_PATH=${HOMEDIR}/apps/pw-linux-package/module"; echo "export DISPLAY=localhost:0.0") >> ${HOMEDIR}/.bashrc
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
OLDIFS=$IFS
IFS=
set +u
PWFILENAME=$(jetpack config PWFileName)
PWFILENAME2=${PWFILENAME//\ /}
if [ ! -f ${HOMEDIR}/apps/pw-linux-package ]; then
   jetpack download "${PWFILENAME}" ${HOMEDIR}/apps/${PWFILENAME2}
fi
if [ ! -d ${HOMEDIR}/apps/pw-linux-package ]; then
   chown ${CUSER}:${CUSER} "${HOMEDIR}/apps/${PWFILENAME2}"
   unzip -o -q "${HOMEDIR}/apps/${PWFILENAME2}" -d ${HOMEDIR}/apps/ 
   mv -f ${HOMEDIR}/apps/${PWFILENAME%.*} ${HOMEDIR}/apps/${PWFILENAME2%.*} | exit 0
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/${PWFILENAME2%.*}
   unzip -o -q ${HOMEDIR}/apps/${PWFILENAME2%.*}/Install/pw-${PW_VERSION}_linux_64.zip -d ${HOMEDIR}/apps/ | exit 0
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/pw-linux-package
fi
chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/pw-linux-package
set -u
IFS=$OLDIFS

# set up user files
if [ ! -f ${HOMEDIR}/pwrun.sh ]; then
   cp ${CYCLECLOUD_SPEC_PATH}/files/pwrun.sh ${HOMEDIR}
fi
chmod a+rx ${HOMEDIR}/pwrun.sh
chown ${CUSER}:${CUSER} ${HOMEDIR}/pwrun.sh

#clean up
popd
rm -rf $tmpdir

echo "end of 10.install_pw.sh"
