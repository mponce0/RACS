#!/bin/bash 

# auxiliary script to monitor RAMdisk and memory utilization
#
# This script is part of
#	 RACS v1.0 (2018/2019) -- Open source tools for Analizing ChIP-Seq data         
#
###########

# instead of using the system fn, 'watch' (usually included in the OS for Linux)
# we will  define our own, so it also works for MacOS
mywatch() {
	msg=" RACS Monitoring Tool \n-------------------- "
	t='2'
	while clear; echo -e $msg; echo -E "`date` -- updated every $t secs" ; eval $@ ; do sleep $t; done
}


# RAMdisk location: given by argument #1 or assumed to be /dev/shm
ramdisk=${1:-"/dev/shm"}
# RACS wokring space location
RACSdir="ORF_RACS-"

# set location to inspect
location="${ramdisk}/${USER}/${RACSdir}*"

# check whether there is an instance of ORF in the 'location'...
[ -d $location ] || warning_Msg="WARNING: workspace <<${location}>> not found! \n  If you are not using the standard (default) location, recall to specify it as an argument when executing this tool."


### Commands ##
## memory and space utilization ##
# check for files generated in the specified location
[ -d $location ] && cmd1=" ls -l $location " || cmd1="echo -e '$warning_Msg' "
# check for memory utilization
cmd2="free -g "
# check for 
[ -d $location ] && cmd3="du -s -h $location " || cmd3="echo -e '$warning_Msg' "
##
## Performance ##
# check for processes
cmd4="ps aux | grep RACS"
##
# separator for separating commands
separator="echo  -----------"
# message
msg="echo Press 'CTRL-C' to exit the monitoring tool..."
##

# combine commmands
obs="$cmd1 ; $separator ; $cmd2 ; $separator ; $cmd4; $separator ; $cmd3 ; $separator ; $msg"

# a first argument equal to 'DBG' can be used for testing purposes
for arg in "$@"; do
	if [ "$arg" == "DBG" ]
	then
		obs="echo '::dbg:: ;;;; running >>> ' ${obs}' <<< ;;;;' ; ${obs}"
	fi
done

# observe...
mywatch  $obs
