#!/bin/bash 
#Prepare directory and data for other scripts
echo \"****** Installing CSC SOE on AliCloud instance ******\" 
echo \"Creating directory /root/csc\" 
mkdir /root/csc 
chmod 755 /root/csc 
chown root:root /root/csc 
echo \"Creating directory /root/logs/firstboot-rc_local\" 
if [ ! -d /root/logs ]; then 
  mkdir /root/logs 
  chmod 755 /root/logs 
  chown root:root /root/logs 
fi 
mkdir /root/logs/firstboot-rc_local/ 
chmod 755 /root/csc 
chown root:root /root/csc 
echo \"Creating directory /etc/rc.local.Pre-CSC/\" 
mkdir /etc/rc.local.Pre-CSC/ 
chmod 755 /root/csc 
chown root:root /root/csc 
version=`uname -mr` 
echo \"linux version $version \" 
if [[ \"$version\" == 2* ]]; then 
  echo \"version 6 csc.ksp\" 
  cp /tmp/soe_harden/csc.rhel6.ksp /root/csc/csc.ksp 
  chmod 744 /root/csc/csc.ksp 
elif [[ \"$version\" == 3* ]]; then 
  echo \"version 7 csc.ksp\" 
  cp /tmp/soe_harden/csc.rhel7.ksp /root/csc/csc.ksp 
  chmod 744 /root/csc/csc.ksp 
fi 
gotDist=\"false\" 
if [[ \"$version\" == 2* ]]; then 
  echo \"version 6 tar\" 
  cp /tmp/soe_harden/RHEL6_CSCdata.v10.tar.gz /tmp/CSCdata.v10.tar.gz 
  chmod 744 /tmp/CSCdata.v10.tar.gz 
  gotDist=\"true\" 
elif [[ \"$version\" == 3* ]]; then 
  echo \"version 7 tar\" 
  cp /tmp/soe_harden/RHEL7_CSCdata.v10.tar.gz /tmp/CSCdata.v10.tar.gz 
  chmod 744 /tmp/CSCdata.v10.tar.gz 
  gotDist=\"true\" 
fi 
if [ \"$gotDist\" == \"true\" ]; then 
  echo \"Unpacking distro and running hardening\" 
  tar -C / -zxf /tmp/soe_harden/CSCdata.v10.tar.gz 
fi 
exit 0
