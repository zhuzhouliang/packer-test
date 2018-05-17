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


echo Prepare log file ok!

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

echo Got UNAME OK
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
cd /tmp/soe_harden
if [ -f "SIP_vendor_install.sh" ]; then
   msg "Installing package via SIP_vendor_install.sh."
   chmod 755 SIP_vendor_install.sh
   	./SIP_vendor_install.sh ${_sip_logfile} 
	_status=$?
elif [ -f "SIP_install.sh" ]; then
   msg "Installing package via SIP_install.sh."
   chmod SIP_install.sh
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

