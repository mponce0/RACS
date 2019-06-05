#!/bin/bash
# -vx

# RACS ORF pipeline
# main script used to analize and call (count) peaks in the T.Thermophila data.
# This script also calls 2 other scripts: "table.sh" and "comb_tables.sh"
# The script requires BWA and samtools to be installed as they are used within the pipeline.

#################
### how to use it
#
# 1st argument: file with INPUT reads (.fastq.gz)
# 2nd argument: file with IP reads (.fastq.gz)
# 3rd argument: reference genome file (.fasta)
# 4th argument: annotiation file (.gff3)
# 5th argument: working space (if possible use RAMdisk --ie. /dev/shm/--, or /tmp in a computer with SSD)
# 6th argument (optional): number of cores to use for BWA multi-threading
#
# Examples:
# time PATHtoRACSrepo/core/countPeaks.sh   _1_MED1_INPUT_S25_L007_R1_001.fastq.gz  _3_MED1_IP_S27_L007_R1_001.fastq.gz  T_thermophila_June2014_assembly.fasta  T_thermophila_June2014.gff3  /tmp/  16
# time PATHtoRACSrepo/core/countPeaks.sh   _1_MED1_INPUT_S25_L007_R1_001.fastq.gz  _3_MED1_IP_S27_L007_R1_001.fastq.gz  T_thermophila_June2014_assembly.fasta  T_thermophila_June2014.gff3  /dev/shm/  16
# 
#################################


#######################################################
# check that the script is not being sourced!!!
if [[ $0 == '-bash' ]]; then
	echo "Please do not 'source' this script; ie. run it as PATHtoRACS/core/SCRIPTname arguments"
	stop
fi

# setting preamble, detecting scripts location
scriptsDIR=`dirname $0`

# load auxiliary fns for integrity checks and message/error handling
if [[ -f $scriptsDIR/auxs/auxFns.sh ]]; then
        . $scriptsDIR/auxs/auxFns.sh --source-only;
else
        echo "Error auxiliary file: " $scriptsDIR/auxs/auxFns.sh "NOT found!"
        exit
fi
#######################################################

#### CHECKS ###########################################
welcome

### CHECK arguments
if [[ $# -eq 0 ]]; then
	errMsg "No arguments supplied!";
fi
#
if [[ $# -lt 5 ]]; then
	errMsg "Five mandatory arguments are needed!";
fi

### CHECK software
checkIntegrityPipeline table.sh comb_tables.sh
checkTools  bwa samtools
######################################################
# define generic names for required programs...
BWA=$(which bwa)
SAMTOOLS=$(which samtools)

# ====================================================
# DEFINE SOME env.VARIABLES
#dataDIR=DATA
#dataDIR=data2
#[ -d $1 ] && dataDIR=$1 || errMsg "1st argument should be a directory, where the reference data to be used is located" 

## reference file
#fastaFILE=$dataDIR/T_thermophila_June2014_assembly.fasta	# <==== this could be another argument!!!
#
#faiFILE=$fastaFILE.fai

## target files
## TO BE READ as arguments... $1 (INPUT) and $2 (IP)
[ -s $1 ] &&  INPUTfile=`basename $1` || errMsg "1st argument should be a file with the INPUT reads (fastq.gz)"
[ -s $2 ] &&  IPfile=`basename $2` || errMsg "2nd argument should be a file with the IP reads (fastq.gz)"
[ -s $3 ] &&  FASTAfile=`basename $3` || errMsg "3rd argument should be a file with the reference genome file (fasta)"
[ -s $4 ] &&  REFfile=`basename $4` || errMsg "4th argument should be an annotation file (gff3)"

faiFILE=$FASTAfile
fastaFILE=$FASTAfile

inputFILE1=INPUTfile
inputFILE2=IPfile

# could be RAMdisk or TEMP in a SSD
# use RAMDISK
#RAMdisk=/dev/shm/$USER/
#RAMdisk=/tmp/$USER/
RunTimeDir=ORF_RACS-$$-`date '+%Y%m%d-%H%M%S'`
[ -d $5 ] && WORKINGdir=$5/$USER/$RunTimeDir || errMsg "6th argument must be a directory, we suggest using /dev/shm for RAMdisk or /tmp in a SSD device, as this pipeline is quite I/O intense!"
echo "Working directory --> " $WORKINGdir


# number of threads to use with BWA
#cores=$(grep -P '^core id\t' /proc/cpuinfo| wc -l)
cores=`detectCores`
#[ -z $6 ] && NT=$6 || NT=$cores
if [ " "$6 != " " ]; then NT=$6 ; else NT=$cores; fi
echo "BWA will use nbrCores="$NT", when possible"

## =====

#inputFILE1=$INPUTfile	#.fastq.gz
#[ -s $inputFILE1 ] || errMsg $inputFILE1" not found" 
#inputFILE2=$IPfile	#.fastq.gz
#[ -s $inputFILE2 ] || errMsg $inputFILE2" not found"

# save original directory
myDIR=$(pwd)
resultsDIR=$myDIR/ORF_RACS_results-`date '+%Y%m%d-%H%M%S'`	#`date +%D-%T`
scriptsDIR=`dirname $0`


# use RAMDISK
#RAMdisk=/dev/shm/$USER/
#RAMdisk=/tmp/$USER/

echo # create local space on RAMDISK
mkdir -p $WORKINGdir
# copy data into WORKINGdir 
#cp -pr ./DATA  $RAMdisk
cp  -prv $1 $WORKINGdir/$inputFILE1
cp  -prv $2 $WORKINGdir/$inputFILE2
cp  -prv $3 $WORKINGdir/$FASTAfile
cp  -prv $4 $WORKINGdir/$REFfile
# move to WORKINGdir
cd $WORKINGdir


# outputs
outputINPUTbam=aln$INPUTfile.bam
outputINPUTbamSORTED=aln$INPUTfile-sorted.bam
outputINPUTsam=aln$INPUTfile.sam
#outputIPbam=alnBD1_IP.bam
#outputIPbamSORTED=alnBD1_IP-sorted.bam
#outputIPsam=alnBD1_IP.sam
outputIPbam=aln$IPfile.bam
outputIPbamSORTED=aln$IPfile-sorted.bam
outputIPsam=aln$IPfile.sam
#output3gzip=/dev/shm/$USER/alnBD1_INPUT.tar.gz

# tables files
tableINPUTs=tableReadsINPUT.`basename $INPUTfile .fastq.gz`
tableIPs=tableReadsIP.`basename $IPfile .fastq.gz`

####=====================================================


## pipeline
# index the assembly
# generates 4 aux. files (in principle could be removed!  -- *.fasta.*)
$BWA index $fastaFILE
#rm *.fasta.*

# align the INPUT to assembly
# bwa -> multithreaded... (upto 4)
$BWA  aln -t $NT  $fastaFILE  $inputFILE1 >  $outputINPUTbam

# convert to sequence coordinate for INPUT
$BWA samse  $fastaFILE $outputINPUTbam $inputFILE1  >  $outputINPUTsam

# remove inputFILE1 in case of memory issues
#rm -v $inputFILE1

#######
# zip file in RAMDISK
#tar cvzf $output3gzip $output2sam
######

# align the IP file to the assembly
# bwa -> multithreaded... (upto 4)
$BWA  aln -t $NT  $fastaFILE  $inputFILE2  >  $outputIPbam

# convert to sequence coordinate for IP
$BWA samse  $fastaFILE $outputIPbam $inputFILE2  >  $outputIPsam

# remove inputFILE2 in case of oom
#rm -v $inputFILE2


# FAI index to the assembly
$SAMTOOLS faidx $fastaFILE


# align assembly witht the sam and bam files
$SAMTOOLS import $faiFILE $outputINPUTsam $outputINPUTbam
$SAMTOOLS import $faiFILE $outputIPsam $outputIPbam

# sorting for IGV
$SAMTOOLS sort $outputINPUTbam -o $outputINPUTbamSORTED
$SAMTOOLS sort $outputIPbam -o $outputIPbamSORTED

$SAMTOOLS index $outputINPUTbamSORTED
$SAMTOOLS index $outputIPbamSORTED


# define table file for extracting genes... passed as third argument to the script!!!
table=table.$REFfile
# extract the reads
touch $tableINPUTs  #tableReadsINPUT
# read scaffolds from table generated by the "table" script and loop over the sorted BAM files
# NEEDS the file "table" generated by the script 'table.sh' // if it doesn't exist, launch its creation in parallel
### [ ! -e $resultsDIR/$table ] || $scriptsDIR/table.sh $REFfile && cp -v $resultsDIR/$table .
$scriptsDIR/table.sh $REFfile
[ $? -ne 0 ] && errMsg "' $scriptsDIR/table.sh $REFfile' FAILED...! exitcode $?"

for i in `awk '{print $1}' < $table `; do
    #echo $i;
    $SAMTOOLS view $outputINPUTbamSORTED $i | wc -l >> $tableINPUTs  #tableReadsINPUT
done

touch $tableIPs   #tableReadsIP
for i in `awk '{print $1}' < $table `; do
    #echo $i;
    $SAMTOOLS view $outputIPbamSORTED $i | wc -l >> $tableIPs  #tableReadsIP
done


#remove temporal files...
rm -v *.fasta.*

### copy data into original directory
mkdir -p $resultsDIR
cp $outputINPUTbamSORTED $outputIPbamSORTED  $resultsDIR
cp $outputINPUTsam $outputIPsam  $resultsDIR
cp $tableINPUTs  $resultsDIR
cp $tableIPs  $resultsDIR
# need the index files for intergenic regions determination
cp *bai $resultsDIR

# FINAL step, combine tables together...
#. $scriptsDIR/comb_tables.sh _2_MED2_INPUT_S26_L007_R1_001 _4_MED2_IP_S28_L007_R1_001 T_thermophila_June2014.gff3 
$scriptsDIR/comb_tables.sh $INPUTfile $IPfile $REFfile
[ $? -ne 0 ] && errMsg "'$scriptsDIR/comb_tables.sh $INPUTfile $IPfile $REFfile' FAILED...! exitcode $?" 
cp -v FINAL.table.*  $resultsDIR

# clean temp dir used
rm -rfv $WORKINGdir 
