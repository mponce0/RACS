#!/bin/bash

# normalizeORF.sh	---     RACS pipeline 
#
# Script utilized to normalize the reads from the ORF
#
#
###
### How to use this script:
#
# This script requires 3 arguments:
#
#   - 1st argument: "FINAL.table.*"  file from RACS' ORF pipeline
#   - 2nd argument: "PF-INPUT-value"  PF value correspoding to the INPUT file
#   - 3rd argument: "PF-IP-value"  PF value correspoding to the IP file
#   - 4th argument: 'A' or 'D' (OPTIONAL), when this 4th argument is specified, an additional table is created being ordered with respect to the IP/INPUT ratio, in "A"scending or "D"ecreasing order 
#
#
# Example:
# 	PATHtoRACS/core/normalizeORF.sh  FINAL.table.XXXX  14694464  10148171 
#       PATHtoRACS/core/normalizeORF.sh  FINAL.table.XXXX  14694464  10148171  A
#
#
#################################


# setting preamble, detecting scripts location
scriptsDIR=`dirname $0`

# load auxiliary fns for integrity checks and message/error handling
if [[ -f $scriptsDIR/auxs/auxFns.sh ]]; then
	. $scriptsDIR/auxs/auxFns.sh --source-only;
else
	echo "Error auxiliary file: " $scriptsDIR/auxs/auxFns.sh "NOT found!"
	exit
fi

#### CHECKS ###########################################
welcome
### CHECK arguments
if [[ $# -eq 0 ]]; then
        errMsg "No arguments supplied!";
fi
#
if [[ $# -lt 3 ]]; then
	errMsg "Three mandatory arguments are needed!";
fi
#######
[ -s $1 ] &&  INPUTfile=`basename $1` || errMsg "1st argument should be the FINAL.table.* file coming from the RACS' ORF pipeline"
#######

# Check values for PF Clusters scores
checkNbr $2 "Second"
checkNbr $3 "Third"

# Check whether the user wants to generate an additional ordered table
if [[ $# -eq 4 ]]; then
	checkOption $4 "Fourth (optional)";
elif [[ $# -gt 4 ]]; then
	errMsg "This script can accept only four arguments!"
fi
	

#######

######################################################

# define name of the new table with normalized entries
normTABLE=normalized--$1

# process the file, adding normalizations...
# first time skip first line from the FINAL.table to avoid its header...
# a second awk is used to avoid division.by.zero, will populate with -- instead
awk -v pfINPUT="$2" -v pfIP="$3" 'NR > 1 {print $0"\t"$5/pfINPUT"\t"$6/pfIP}{next}' $1 | awk '{ if ($7==0) print $0"\t""--"; else print $0"\t"($8/$7)}' > $normTABLE

# let's sort the normalized table by the ratio...
if [[ $4 == "A" ]]; then
	echo "sorting normalized table in 'A'scending order...";
	sort -k 9 $normTABLE > $normTABLE--SORTED;
elif [[ $4 == "D" ]]; then
	echo "sorting normalized table in 'D'esceding order...";
	sort -k 9 -r $normTABLE > $normTABLE--SORTED;
fi

# Add header to the new files
header=`head -1 $1`" \t normalized.INPUT \t normalized.IP \t normalized.IP.INPUT.ratio"

if [[ $4 -eq "A" || $4 -eq "D" ]]; then
	TABLES=$normTABLE--SORTED" "$normTABLE;
else
	TABLES=$normTABLE;
fi

echo $TABLES
for table in $TABLES; do
	echo $table;
	echo -e $header | cat - $table > tmp && mv tmp $table
done


#######################################################################################
