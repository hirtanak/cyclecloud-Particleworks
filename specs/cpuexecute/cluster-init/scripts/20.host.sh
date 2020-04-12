#!/usr/bin/bash

echo "starting 20.hostconfig node set up"

LICENSE=$(jetpack config LICENSE)
HOSTIP1=${LICENSE##*@}
HOSTNAME1=$(jetpack config Hostname1)
sed -i -e "3a ${HOSTIP1}\ ${HOSTNAME1}" /etc/hosts


echo "ending 20.hostconfig node set up"
