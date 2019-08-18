#!/bin/bash

# utility script to check for running RACS' processes 
#
# Usage:
#	pathTOracs/tools/check_RACS_processes.sh
#
# This script is part of
#        RACS v1.0 (2018/2019) -- Open source tools for Rapid Analisys of ChIP-Seq data         
#
###########

#######################################################
# check that the script is not being sourced!!!
if [[ $0 == '-bash' ]]; then
        echo "Please do not 'source' this script; ie. run it as PATHtoRACS/core/SCRIPTname"
	return 
fi

# setting preamble, detecting scripts location
scriptDIR=`dirname $0`
# get the absolute path of RACS...
scriptsDIR=$( cd "${scriptDIR}" && pwd )
#######################################################


# check for RACS keyword
ps aux -U $USER | grep -i RACS | grep -v "grep"


# check for any of the possible scripts of the RACS pipeline...
possible_scripts=`cat $scriptsDIR/../core/test/lst`

for i in ${possible_scripts}; do
	#echo $i; echo `basename $i`;
	ps aux -U $USER | grep -i $i | grep -v "grep" ;
	ps aux -U $USER | grep -i `basename $i` | grep -v "grep";
done
