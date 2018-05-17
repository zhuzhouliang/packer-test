#! /usr/bin/env sh

#set -x

# trap interupts
trap 'cleanup && exit 1' 1 2 15

# assumptions
# - only called from a SIP
# - only need to deal with vendor packages in the cwd
# - root ran us
# - current platform support already checked in SIP header
# - users never run us directly, so no need to provide help
# - space has already been checked, or we wouldn't have been extracted
# - we will be silent, and print to logfile 
# - logfile is only option on command line ($1)
# - 


# TODO
# 1. implement and test HP,SUN,Linux,AIX pkg install
# 2. check for successful installation
_sip_logfile=$1
_status=0
_uname=`(uname -s) 2>/dev/null` || _uname=unknown
_pwd=`pwd`

case $_uname in
   HP-UX) _pkg=`ls ${_pwd} | grep depot | sed -e "s/.depot//" `
          _inst_cmd="/usr/sbin/swinstall -x mount_all_filesystems=false  -x reinstall=true -s ${_pwd}/*.depot ${_pkg}"
          _echo="echo"
         ;;
   SunOS) _inst_cmd="/usr/sbin/pkgadd -a ${_pwd}/admin -d ${_pwd}/*.pkg all"
          _echo="echo"
         ;;
   Linux) _inst_cmd="rpm -ivU --force --nodeps  *.rpm "
          _echo="echo -e"
         ;;
   AIX)   _inst_cmd="/usr/sbin/installp -ac -FNQX -d${_pwd} all"
          _echo="echo"
         ;;
esac   

# function purpose:   print and log messages, respects silent option
msg() {
   _message_msg="$*"
   shift $#
   $_echo "`date +%y/%m/%d.%Hh%M` ${_message_msg}"  >> ${_sip_logfile}
   unset _message_msg
   return 0
} # msg


# function purpose:   cleans up tmp files and dirs
cleanup() {
 msg "nothing to cleanup here?"
}


# main
umask 022
mkdir -p /opt/soe/local
unalias rm cp mv 2>/dev/null

if [ -d /opt/soe/local/perl/assets ] ; then
    echo " ERROR : **** /Perl_PS already installed , Installation abandoned ****" 2>&1 | tee -a $_sip_logfile
    exit 1
fi

#if [ -f /etc/redhat-release ] ; then
#ver=`rpm -q -f --queryformat '%{VERSION}' /etc/redhat-release`
# if [[ "$ver" != "5" && "$ver" != "5Server" && "$ver" != "5Client" && "$ver" != "5.11Server"  && "$ver" != "5.11Workstation"  && "$ver" != "5.11" ]]; then
#       echo "It is not Red Hat 5 server/workstation or CentOS/OEL 5. Hence aborting installation..." 2>&1 | tee -a $_sip_logfile
#        exit 1
#  fi
#fi


#run install
( $_inst_cmd 2>&1; $_echo $? > cmd_status ) | tee -a $_sip_logfile

touch cmd_status
_status=`cat cmd_status`

msg "status is $_status\n"

# check status
# this is an example of removinf old version of the rpms...
if [ "$_status" = "0" ]; then
     rpm -e   SOE_perl-5.8.2-0         2>/dev/null
     rpm -e  SOE_perl-5.8.8-0         2>/dev/null
     rpm -e  SOE_perl-5.10.0-0        2>/dev/null
     rpm -e  SOE_perl-5.10.0-2		2>/dev/null
      rpm -e  SOE_perl-5.20.0-0          2>/dev/null
      rpm -e  SOE_perl-5.20.0-2          2>/dev/null
    
fi
# exit - passing install command status up!
exit $_status

if [ -d /opt/soe/local/perl/assets ] ; then
    echo " ERROR : **** /Perl_PS already installed1 , Installation abandoned ****"
    exit 1
fi #if [ -d /opt/soe/local/perl-5.8.7 ] ; then
#rm -rf /opt/soe/local/perl-5.8.7 2>/dev/null 
#fi
if [ -d /opt/soe/local/perl-5.8.2 ] ; then
rm -rf /opt/soe/local/perl-5.8.2 2>/dev/null
fi
if [ -d /opt/soe/local/perl-5.10.0 ] ; then
rm -rf /opt/soe/local/perl-5.10.0 2>/dev/null
fi
if [ -d /opt/soe/local/perl-5.20.0 ] ; then
rm -rf /opt/soe/local/perl-5.20.0 2>/dev/null
fi

#%preun # only run the postun if we are removing the last instance from the box
if [ "$1" = 0 ];
then

 # Remove product directory
  rm -rf /opt/soe/local/perl-5.22.1 >/dev/null 2>&1
  rm -rf /opt/soe/local/perl
if [ -d /opt/soe/local/bin ] ; then
cd /opt/soe/local/bin
rm -rf a2p  enc2xs perl5.8.8 perl5.10.0 perl5.14.2  perlivp pod2latex  podchecker  s2p   dprofpp  h2xs  perl
rm -rf c2ph     find2perl  libnetcfg    perlbug    piconv    pod2man    podselect   xsubpp
rm -rf cpan     h2ph       perlcc     pl2pm     pod2text   psed        
rm -rf perldoc pod2usage splain pod2html pstruct
fi

if [ -d /opt/soe/local/man/man1 ] ; then

cd /opt/soe/local/man/man1
rm -rf perl*
rm -rf pod*
rm -rf a2* h2* c2* pl2* 
rm -rf cpan.1 dprofpp.1 enc2xs.1 find2perl.1 libnetcfg.1
rm -rf piconv.1 psed.1 pstruct.1 s2p.1 splain.1 xsubpp.1
 
fi

if [ -d /opt/soe/local/man/man3 ] ; then 

cd /opt/soe/local/man/man3
rm -rf Pod* File* Get* Any* Att* Auto* auto* B* bi* by* Ca* CG* CP* Dev* att* bas* blib* char*  Clas* Conf* const*
rm -rf C* D* E* IO* IP* Lis* Loca* Math* Memo* Mime* Per* Thr* Tie* Uni* Use* XS* Tex* F* G* Net* ND* op* SD* Term*
rm -rf Test* Tim* v*  war*  Win* th* S* MIM* I18* Hash* POSIX* strict*  sort* sig* lib* less* integer* field* encod*
rm -rf diagnostics.3 filetest.3 if.3 locale.3 NEXT.3 O.3 Opcode.3 overload.3 re.3 subs.3 UNIVERSAL.3 utf8.3
fi 
