#!/bin/bash
#Install base utilities for other steps
version=`uname -mr`
yum update -y 
yum install perl -y 
yum install sysstat.x86_64 -y 
yum install redhat-lsb-core.x86_64 -y 
yum install curl -y 
yum install yum-versionlock -y 
if [[ \"$version\" == 2* ]]; then
#rhel 6
  echo \"RHEL 6 CloudWatchDiskAndMemoryMonitoring\"
  yum install perl-DateTime perl-CPAN perl-Net-SSLeay perl-IO-Socket-SSL perl-Digest-SHA gcc -y
  yum install zip unzip -y
  export PERL_MM_USE_DEFAULT=1
  export PERL_EXTUTILS_AUTOINSTALL=\"--defaultdeps\"
  cpan YAML
  cpan LWP::Protocol::https
  cpan Sys::Syslog
  cpan Switch
elif [[ \"$version\" == 3* ]]; then
#rhel 7
  echo \"RHEL 7 CloudWatchDiskAndMemoryMonitoring\"
  yum install zip unzip perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA -y
fi
