# table.sh file, part of RACS ORF pipeline
#
# This script is internal to the RACS ORF pipeline, and it is called from
# "countReads.sh"
# However this script can be used separatedly for generating
# tables of ORF for a given organism and targets
#
# The script accepts two arguments:
#
#  1st) a mandatory argument specifying the name of the reference file (gff3)
#
#  2nd) an optional argument indicating the configuration file of the target
#  terms to identify within the reference file.
#  If the second argument is not indicated, the script will assume the
#  definitions for the Tetrahymena Thermophila provided by our pipeline
#  included in the "TT_gene.id" file
#
#####################################################################


######
######
# setting preamble, detecting scripts location
scriptsDIR=`dirname $0`

# load auxiliary fns for integrity checks and message/error handling
if [[ -f $scriptsDIR/auxs/auxFns.sh ]]; then
        . $scriptsDIR/auxs/auxFns.sh --source-only;
else
        echo "Error auxiliary file: " $scriptsDIR/auxs/auxFns.sh "NOT found!"
        exit
fi
######
######


#### CHECKS ###########################################
### CHECK arguments
if [[ $# -eq 0 ]]; then
        errMsg "No arguments supplied!";
fi
#
if [[ $# -lt 1 ]]; then
        errMsg "At least one mandatory argument is  needed!";
fi
######################################################
# Process command-line arguments
# 1st argument - MANDATORY: name of the reference file to process...
# eg. FILE=T_thermophila_June2014.gff3
FILE=$1
echo "Verifying $FILE..."
checkFile $FILE
FILEname=`basename $FILE`

# 2nd argument - OPTIONAL: if a second argument is specified,
# it should contain the definition of the filters and targets for the
# ORGANISM; otherwise if there is no 2nd argument, the script will
# assume the definitions for the Tetrahymena Thermophila provided
# by our pipeline in the "TT_gene.id" file
if [ " "$2 != " " ]; then ORGANISM=$2 ; else ORGANISM="$scriptsDIR/auxs/TT_gene.id"; fi

echo "checking for organism defns in $ORGANISM"
checkFile $ORGANISM
######################################################


#####################################################################
#####################################################################
# load details of the organism, i.e. filters, targets, etc.
. $ORGANISM
#####################################################################
#####################################################################



################## selection ... #####################################

# grab scafold and genes' range
grep $filter1 $FILE | grep $filter2 | awk '{print $1" "$4"-"$5}' > tmp0.$FILEname

# grab "TTHERM", ie. *delim1*
# grep $filter1 $FILE | grep $filter2 | awk 'BEGIN{FS="TTHERM"} {print $2}' | awk	'BEGIN{FS=";Note"} {print "TTHERM"$1}' > tmp1.$FILE
grep $filter1 $FILE | grep $filter2 | awk  -v d1="$delim1" 'BEGIN{FS=d1} {print $2}' | awk -v d1="$delim1" -v d2="$delim2" 'BEGIN{FS=d2} {print d1$1}' > tmp1.$FILEname

# grab 'Note' and replace 'spaces' with 'underscores (_)'
#grep $filter1 $FILE | grep $filter2 | awk 'BEGIN{FS="Note="} {print "Note="$2}' | sed 's/ /_/g' > tmp2.$FILE
grep $filter1 $FILE | grep $filter2 | awk -v d3="$delim3" 'BEGIN{FS=d3} {print d3$2}' | sed 's/ /_/g' > tmp2.$FILEname

# compute gene size
grep $filter1 $FILE | grep $filter2 | awk '{print $5-$4+1}' > tmp3.$FILEname

#######################################################################

# join sliced data (tmp.files) to generate a combined table
#paste tmp0 tmp1 tmp2 tmp3
paste tmp0.$FILEname tmp1.$FILEname tmp2.$FILEname tmp3.$FILEname | sort  -k 1 | sort -t: -n -k 2  | awk '{print $1":"$2"\t"$3"\t"$4"\t"$5"\t"$6}' > table.$FILEname

# cleanup: remove temporary files...
#rm tmp0 tmp1 tmp2 tmp3
rm -v tmp?.$FILEname


#######################################################################
#######################################################################
