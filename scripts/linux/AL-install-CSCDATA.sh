echo \"downloading hardening software\" 

cd /tmp/soe_harden 
# expand harden script 
gunzip SOE-harden-3.1-5-linux-x86_64-client-SIP.sh.gz
chmod 755 SOE-perl-5.22.1-0-linux-redhat-SIP.sh
sh ./SOE-perl-5.22.1-0-linux-redhat-SIP.sh -i 
if [[ ! $? -eq 0 ]]; then 
  echo \"issue executing DXC hardening script: SOE-perl-5.22.1-0-linux-redhat-SIP.sh\" 
  exit 1 
fi 
HOLD_PATH=$PATH 
PATH=/opt/soe/local/perl/bin:$PATH 
echo Begin to install rpm
rpm -i SOE_csc_ti_client-10.1-0.x86_64.rpm
echo Install rpm ok

PATH=$HOLD_PATH 
echo \"hardening successful\" 
exit 0 \n"