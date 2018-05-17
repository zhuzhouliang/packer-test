#!/bin/bash
#
echo Backing up ifcfg-eth0 before we begin
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /root/ifcfg-eth0.bak

echo Running CSC Custom rc.local Script
for i in `ls CSCdata/firstboot-rc_local/`
do
  if [ -x $i ]
  then
    log="`basename $i`.log"
    echo "INFO: Executing ${i}..."
    $i boot 2>&1 | tee /root/logs/firstboot-rc_local/${log}
    if [ $? -eq 0 ]; then chmod 600 $i ; fi
  fi
done
echo Restoring original ifcfg-eth0
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /root/ifcfg-eth0.aftersoe
mv /root/ifcfg-eth0.bak /etc/sysconfig/network-scripts/ifcfg-eth0

# exit 0 to stop reporting erroneous errors to ansible
exit 0
