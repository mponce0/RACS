#!/bin/bash

# auxiliary script to monitor RAMdisk and memory utilization
#
# This script is part of
#	 RACS v1.0 (2018/2019) -- Open source tools for Analizing ChIP-Seq data         
#
###########


# RAMdisk location
ramdisk="/dev/shm"
RACSdir="ORF_RACS-"

# set location to inspect
location="${ramdisk}/${USER}/${RACSdir}*"

# Commands
# check for files generated in the specified location
cmd1="ls -l $location "
# check for memory utilization
cmd2="free -g "
# check for 
cmd3="du -s -h $location "
# separator for separating commands
separator="echo -----------"
# message
msg="echo Press 'CTRL-C' to exit the monitoring tool..."

# combine commmands
obs="$cmd1 ; $separator ; $cmd2 ; $separator ; $cmd3 ; $separator ; $msg"

# for testing purposes
obs="echo '*-*'$obs'-*-' ; $obs"

# observe...
watch $test
