#!/usr/bin/bash

echo "starting 20.hostconfig node set up"

LICENSE=$(jetpack config LICENSE)
HOSTIP1=${LICENSE##*@}
HOSTNAME1=$(jetpack config Hostname1)
sed -i -e "3a ${HOSTIP1}\ ${HOSTNAME1}" /etc/hosts

###sed -i -e "3a 13.78.58.91\ licensevm01" /etc/hosts
sed -i -e "4a 20.188.11.146\ licensevm02" /etc/hosts
sed -i -e "5a 70.37.51.75\ licensevm03" /etc/hosts

echo "ending 20.hostconfig node set up"
