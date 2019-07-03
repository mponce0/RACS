# interGenes.sh	---	RACS pipeline
#
# shell script part of the RACS InterGenic Regions determination
# this script is part of the IGR RACS tool, use "det-interGenes.sh" instead!
# this script should receive 3 arguments
# 
# arg1: a label to annotate the produced files
# arg2: alnXXXX.fastqc.gz-sorted.bam file produced when running the ORF RACS pipeline tool 
# arg3: table contanining the IGR
#
# Eg. call the script with BDx_{INPUT/IP}_NSG  interGENs.csv
##  . ../newSCRIPTS/interGenes.sh  INPUTm1  alnFillingham_1_MED1_INPUT_S26_L007_R1_001.fastq.gz-sorted.bam  interGENs_MED1-MED2.csv
#
##################################################
# setting preamble, detecting scripts location
scriptsDIR=$( cd `dirname $0` && pwd )


# load auxiliary fns for integrity checks and message/error handling
if [[ -f $scriptsDIR/../auxs/auxFns.sh ]]; then
        . $scriptsDIR/../auxs/auxFns.sh --source-only;
else
	echo "Error auxiliary file: " $scriptsDIR/../auxs/auxFns.sh "NOT found!"
	exit
fi
#################################################

# display RACS welcome message
welcome

#### CHECKS
### INTEGRITY CHECKs
# check external tools needed
checkTools samtools

#################################################

echo 'hello'
echo $#
echo $@

### CHECK arguments
case $# in
	3) echo $# "Arguments received:"; echo $@;;
	*) errMsg "Invalid number of arguments!"; usage ;;
esac

#########

HEADER=$1
src=$2
#bamSORTEDfiles=aln$src-sorted.bam
bamSORTEDfiles=$2
interGENregions=$3
table_interGENs=interGENs-$src.csv	#--`date '+%Y%m%d-%H%M%S'`.csv

# check arguments: verify that input files exist...
checkFile $interGENregions $bamSORTEDfiles

# check if there was a previous version of IGR table, and if so renamed it
# [[ -s $table_interGENs ]] && mv -v  $table_interGENs  $table_interGENs-PREVIOUS_`date '+%Y%m%d-%H%M%S'`.csv

# generate header
echo $table_interGENs"::"$HEADER > $table_interGENs


# count reads ...
for i in `awk '{ if (NR>1) print $1}' < $interGENregions `; do
    #echo $i;
    samtools view $bamSORTEDfiles $i | wc -l >> $table_interGENs
done

####################################################################
