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

gunzip SOE-csc_ti-10.1-0-linux-x86_64-client-SIP.sh.gz
chmod 755 SOE-csc_ti-10.1-0-linux-x86_64-client-SIP.sh
sh ./SOE-csc_ti-10.1-0-linux-x86_64-client-SIP.sh -i 
if [[ ! $? -eq 0 ]]; then 
  echo \"issue executing DXC hardening script:SOE-csc_ti-10.1-0-linux-x86_64-client-SIP.sh\" 
  exit 1 
fi 

gunzip SOE-harden-3.1-5-linux-x86_64-client-SIP.sh
chmod 755 SOE-harden-3.1-5-linux-x86_64-client-SIP.sh
sh ./SOE-harden-3.1-5-linux-x86_64-client-SIP.sh -i 
if [[ ! $? -eq 0 ]]; then 
  echo \"issue executing DXC hardening script:SOE-harden-3.1-5-linux-x86_64-client-SIP.sh\" 
  exit 1 
fi 

PATH=$HOLD_PATH 
echo \"hardening successful\" 
exit 0 \n"