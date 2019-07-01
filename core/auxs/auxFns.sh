#!/bin/bash
## -vx

# auxiliary set of functions used in other scripts
# it includes:
#	- welcome(): RACS welcome message and credits
#
#	- helpMsg(): help message describing how to use this script
#
#	- usage(): an improved self-documented help fn based on the same scripts' comments
#
#	- checkTools(): fn to check the availability of a given tool
#			by looking whether such an executbale/program is present in the current system;
#			the fn can process several arguments at once
#
#	- checkIntegrityPipeline(): fn to check internal scripts to the pipeline,
#			the fn will check whether an specific script exists and has an executable attribute;
#			the fn can process several arguments at once
#
#################################


### functions ########################################

##### Informative fucntions
welcome() {
	echo "RACS v1.0 (2018/2019) -- Open source tools for Analizing ChIP-Seq data"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

}

##

helpMsg(){
	scriptsDIR=$( cd "`dirname $0`" && pwd )	#`dirname $0`
	welcome
	echo $scriptsDIR
	echo "How to use this script:"
	more $scriptsDIR/../../README
	cancel;
}
##
usage() {
	shebang="#!/bin/bash"
	scriptName=`basename $0`
	scriptsDIR=$( cd "`dirname $0`" && pwd )	#`dirname $0`
	welcome
	echo "************************"
	echo $scriptName
	echo "************************"
	echo "How to use this script:"
	upto=$(grep -v $shebang $0 | grep -n "####################" | head -1 | awk -F":" '{print $1}')
	grep -v $shebang $0 | head -$upto | more
	exit 222
}

##

##### Checking/Testing Functions
checkTools(){
	echo "checking for tools required for RACS..." 
	for tool in "$@"; do
		# look for the 'tool' in executable path
		statusTOOL=$(which $tool);
		# if status is null => tool NOT found!
		[ -z $statusTOOL ] && errMsg "$tool needs to be installed for using this pipeline!" || echo "	 $tool ... found!"
	done
}

#####

checkIntegrityPipeline(){
	echo "Verifying RACS integrity..." 
	scriptsDIR=$( cd "`dirname $0`" && pwd )	#`dirname $0`
	for dep in "$@"; do
		# this will make the fn look in the location from where the fn is being called, ie. relative to the location of the calling script...
		testing=$scriptsDIR/$dep
		#echo $testing
		# check file exists and has execution attribute
		[ -x $testing ]  && echo "	 $dep ... ok!" || errMsg "err.critical: missing '$dep' from pipeline directory $scriptsDIR: $testing" 
	done
}

#########

#####
# Functions for checking command-line arguments
#####

# Function that checks whether the argument is an existing file
checkFile() {
	for file in "$@"; do
		echo 'verifying file...' $file
		[ ! -f $file ] && errMsg "File $file NOT found!"
	done
}


#########

# Function that checks that the argument is of type numeric, ie. an integer number
checkNbr() {
	numericDigits='^[0-9]+$'
	if ! [[ $1 =~ $numericDigits ]] ; then
		errMsg "$2 argument should be a positive integer number! Check your PF cluster information!"
	fi
}

#########

#Function that checks whether the argument is of a particular type
checkOption() {
	if [[ $1 != "A" && $1 != "D" ]] ; then
		errMsg "$2 argument should be either 'A' for ascending or 'D' for decreasing order!"
	fi
}

#########

######
# Other miscellaneous fns
######


# Function to detect number of cores

detectCores() {
	nbrCores=$(grep -P '^core id\t' /proc/cpuinfo| wc -l)
	echo $nbrCores
}


# functions to time execution

tick() {
	t0=`date +%s`
}

tock(){
	t1=`date +%s`
	echo $((t1-t0))
}

########################################################

######################################################
# helper fns for handling error messages
pausee() { echo "----------------------------------------"; read -p "$*"; }
msg() { echo "$0: $*" >&2; }
errMsg() { msg "$*"; pausee 'Press [Enter] to continue...'; usage;  return 1 2>/dev/null; exit 1;}
try() { "$@" || errMsg "cannot $*"; }
#######################################################

######################################################

# ====================================================
myDIR=$(pwd)
resultsDIR=$myDIR/results-`date '+%Y%m%d-%H%M%S'`	#`date +%D-%T`


