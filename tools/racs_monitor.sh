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

# Commands
# check for files generated in the specified location
cmd1=" ls -l $location "
# check for memory utilization
cmd2="free -g "
# check for 
cmd3="du -s -h $location "
# separator for separating commands
separator="echo  -----------"
# message
msg="echo Press 'CTRL-C' to exit the monitoring tool..."

# combine commmands
obs="$cmd1 ; $separator ; $cmd2 ; $separator ; $cmd3 ; $separator ; $msg"

# a first argument equal to 'DBG' can be used for testing purposes
for arg in "$@"; do
	if [ "$arg" == "DBG" ]
	then
		obs="echo '::dbg:: ;;;; running >>> ' ${obs}' <<< ;;;;' ; ${obs}"
	fi
done

# observe...
mywatch  $obs
