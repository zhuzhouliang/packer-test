#! /usr/bin/env sh
## CVS version line goes here
# This is the default self-installing-package script for an SOE package.
#
# The header of this script should just print metadata by default,
# If the install option is given then it will:
#  - extract the "package",
#  - runn SIP_install.sh, and
#  - check the return codes.

## Note: Error codes - 0 for success, and anything else is bad
# Return code:	1 - generic problem
#		2 - not a root user
#               3 - not enough space to extract

#mandatory metadata fields
_product_name=SOE_perl
_product_revision=5.22.1-0
_product_date=1469148144
_os=linux
_os_version='5'
_distro='redhat|centos|oel|CentOS|OEL'
_distro_version='5'
_machine=*
_os_bit=
# size (Kb) required of extract directory
_sip_workspace_size="16484"
_sip_installed_size="62681"

#optional metadata fields
_summary="'SOE Perl 5.22.1-0 - Practical Extraction and Reporting Language'"
#_description=
_requires=""
_supersedes="(none)"
_sip_compression=0
_sip_coded=0

#other variables
_extract_dir="extract.$$"
_home=`pwd 2> /dev/null`
_script=`basename $0`
_script_dir=`dirname $0`
# this is great unless it is a relative path.... so let's check it
_start_char=`echo ${_script_dir} | cut -c 1`
if [ ${_start_char} != "/" ]; then
  _script_dir="${_home}/${_script_dir}"
fi
_sip_logfile=${_home}/${_script}.log
_uid="`id | sed 's/(.*$//' | sed 's/uid=//'`"

#this magic value is the number of lines to skip to "get at" the SIP content
_skip=`awk '/^__ARCHIVE_FOLLOWS__/ { print NR + 1; exit 0; }' $0`

#global status variable, set to success to start out
_status=0


# First check that we are root - generally need to be root to install software
check_root()  {
if [ "${_uid}" -ne 0 ]; then
   echo ""
   echo "ERROR: must be root to run ${_script}."
   exit 2
fi
}

# Next check platform for echo, and du/df/bdf commands
_uname=`(uname -s) 2>/dev/null` || _uname=unknown
if [ $_uname = "Linux" ]; then
_deb_chk=`lsb_release -sd 2>/dev/null| cut -c -6 `
if [ "$_deb_chk" = "Ubuntu" ]; then
        _uname="Ubuntu"
fi
fi


# set echo and df commands
case $_uname in
   HP-UX) _df="bdf"
          _echo="echo"
         ;;
   SunOS) _df="df -k"
          _echo="echo"
         ;;
   Linux) _df="df -k"
          _echo="echo -e"
         ;;
   AIX) _df="df -kP"
          _echo="echo"
         ;;
  Ubuntu) _df="df -k"
	 _echo="echo"
	 ;;
   CYG*) _df="df -k"
          _echo="echo"
         ;;
   *) echo "ERROR: ${_script} is not supported on this system" 
      exit 2
      ;; 
esac   

# function purpose:   print and log messages, respects silent option
msg() {
   _message_msg="$*"
   shift $#
   
   if [ -z "${_silent}" ]; then
      $_echo "${_message_msg}" 
   fi
   $_echo "`date +%y/%m/%d.%Hh%M` ${_message_msg}"  >> ${_sip_logfile}

   unset _message_msg
   return 0
} # msg

# trap interupts
trap 'cleanup && exit 1' 1 2 15

# function purpose:   cleans up tmp files and dirs
cleanup() {
  cd ${_home}
  if [ -d ${_extract_dir} ]; then
    msg "Removing extract directory - ${_extract_dir}."
    rm -rf ${_extract_dir}
  fi
}

# function purpose:   prints the metatdata
print_metadata() {
   $_echo "product_name::${_product_name}"	
   $_echo "product_revision::${_product_revision}"	
   $_echo "product_date::${_product_date}"	
   $_echo "summary::${_summary}"		
   #$_echo "description::${_description}"	
   $_echo "os::${_os}"				
   $_echo "os_version::${_os_version}"		
   $_echo "distro::${_distro}"			
   $_echo "os_bit::${_os_bit}"
   $_echo "distro_version::${_distro_version}"	
   $_echo "machine_type::${_machine}"		
   $_echo "requires::${_requires}"		
   $_echo "supersedes::${_supersedes}"		
   $_echo "sip_workspace_size::${_sip_workspace_size}"	
   $_echo "sip_installed_size::${_sip_installed_size}"	
   $_echo "sip_compression::${_sip_compression}"	
   $_echo "sip_coded::${_sip_coded}"			
   $_echo "sip_gzipped::${_sip_gzipped}"		

   return 0
}

# function purpose:   provide help
help() {
   msg ""
   usage
   msg ""
   msg The options are:
   msg ""
   msg "-h	:get this help and exit"
   msg "-m	:print the metadata (suitable for programmatic use) and exit"
   msg "-e	:just extract the \"package\" and exit"
   msg "-i	:run the installation of this SIP"
   msg "-l  xx  :override log file with xx"
   msg "-S	:silent"
   msg ""

   return 0
} # help


# function purpose:   show usage of program
usage() {
   msg "Usage: ${_script} [-m|-e|-h|-i|-S|-l log]"
   msg " Help: ${_script} -h"
   return 0
}

# function purpose:   return the size in (Kb) of a FS for a given dir
get_size() {
   _dir=$1
   if [ ! -d $_dir ] ; then
      echo "Directory $_dir does not exist"
      return 1
   fi
   _fs_info=`$_df $_dir | grep -v '^Filesystem'`
   if [ $? -ne 0 ] ; then
      echo "$_df $DIR failed"
   fi
   _fs_name=`echo $_fs_info | awk '{ print $1 }'`
   _fs_avail=`echo $_fs_info | awk '{ print $4 }'`
}


# function purpose:   check space, create extract dir, extract tar file
#                     respect compression and encode vars
extract_package() {

   # create the extraction area
   msg "Making tmp extract directory - ${_extract_dir}."
   mkdir -p ${_extract_dir}

   # check that there is enough room to extract the package
   get_size ${_extract_dir}
   if [ $_sip_workspace_size -ge $_fs_avail ]; then
      msg "This SIP requires $_sip_workspace_size Kb in $_fs_name to be extracted.\nIt looks like there is only $_fs_avail Kb available, so we will abort."
      exit 3
   fi
   cd ${_extract_dir}
 
   # extract the package, uncompress, gunzipping, and uudecoding as necessary
   if [ "${_sip_coded}" -eq "1" ]; then
      if [ "${_sip_compression}" -eq "1" ]; then
         uudecode ${_script_dir}/${_script}
         uncompress SIP-content.tar.Z
         tar xf SIP-content.tar
	 #check status
         rm SIP-content.tar
      else
         uudecode ${_script_dir}/${_script}
         tar xf SIP-content.tar
         rm SIP-content.tar
      fi
   else
   
	
      if [ "${_sip_compression}" -eq "1" ]; then

		if [ `uname -s ` = "Linux" ]; then
                tail -n +$_skip ${_script_dir}/${_script} | uncompress -c | tar xf -
                else
                tail  +$_skip ${_script_dir}/${_script} | uncompress -c | tar xf -
                fi
      else
		if [ `uname -s ` = "Linux" ]; then
              tail -n +${_skip} ${_script_dir}/${_script} | tar xf -
               else
	         tail +${_skip} ${_script_dir}/${_script} | tar xf -
               fi


      fi


fi

   # if extraction only is specified on cmd line, then exit now
   if [ -n "${_extract_only}" ]; then
     msg "Note: -e option specified, package has been extracted to ${_extract_dir}, exiting without installing or cleaning up.\n"
     exit 0
   fi
   return 0
}

# function purpose:   put a banner in the log
start_log() {
   $_echo "`date +%y/%m/%d.%Hh%M` NOTE: Starting $0."  >> ${_sip_logfile}
   return 0
}



# mainline of script (other than checking if root)

# get and check options
set -- `getopt Shmveil: $*`
if [ $? -ne 0 ]; then
   help
   exit 1
fi

while [ $# -gt 0 ]
do
   case $1 in
   -h)				# print usage and help message
      help
      exit 0
      ;;
   -m)				# just print meta data and exit
      print_metadata
      exit 0
      ;;
   -S)                          # run silent
      _silent="true"
      shift
      ;;
   -e)				# just extract the package
      check_root
      start_log
      _extract_only="true"
      extract_package
      exit 0
      ;;
   -i)				# yeah - install it
      _install="true"
      shift 
      ;;
   -l)				# override the default logfile
      _sip_logfile=$2
      shift 2
      ;;
   --)
      shift
      break
      ;;
   esac
done

# if there are still options left then they don't understand how to "use" us
if [ $# -ne 0 ]; then
    usage
    exit 1
fi  

check_root
start_log

# default behaviour is to print info and get out - this is normal
if [ -z "${_install}" ]; then
      _silent=""
   msg "\nBy design this program does NOT install by default.\n"
   msg "\nThis package has the following attributes:\n"
   print_metadata
   msg "\nRun ${_script} -h for more help.\n"
   exit 0
else 
   msg "Installing ${_product_name}.\n"
fi

# extract the package (handles space, compression, and encoding factors)
extract_package
# we are now in the extract dir

#check status of extraction

# if SIP_vendor_install.sh exists, then run it
  # check for a successful installation
# else if SIP_install.sh exists, then run it
  # check for a successful installation
if [ -f "SIP_vendor_install.sh" ]; then
   msg "Installing package via SIP_vendor_install.sh."
   	./SIP_vendor_install.sh ${_sip_logfile} 
	_status=$?
elif [ -f "SIP_install.sh" ]; then
   msg "Installing package via SIP_install.sh."
   	./SIP_install.sh ${_sip_logfile}
	_status=$?
else 
   msg "No install script found in this package. Exiting without cleaning up."
   exit 4
fi

# check status of install

# cleanup tmp dirs
cleanup

# exit normally ?
exit $_status

# everything above the next line is a shell script, everything below it is not
__ARCHIVE_FOLLOWS__
SIP_vendor_install.sh                                                                               0000755 0000000 0000000 00000005375 12744175747 013705  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   #! /usr/bin/env sh

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

if [ -f /etc/redhat-release ] ; then
ver=`rpm -q -f --queryformat '%{VERSION}' /etc/redhat-release`
 if [[ "$ver" != "5" && "$ver" != "5Server" && "$ver" != "5Client" && "$ver" != "5.11Server"  && "$ver" != "5.11Workstation"  && "$ver" != "5.11" ]]; then
       echo "It is not Red Hat 5 server/workstation or CentOS/OEL 5. Hence aborting installation..." 2>&1 | tee -a $_sip_logfile
        exit 1
  fi
fi


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
