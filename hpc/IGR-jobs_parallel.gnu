#!/bin/bash 
#
## example of a sequence of RACS IGR jobs using GNU-parallel

#####
errMsg() { msg "$*"; helpMsg;  exit 111;}
####

# this script requires GNU-PARALLEL to work, so let's first
# be sure that it installed in the system...
GNUPARALLEL=$(which parallel)
[ -z $GNUPARALLEL ] && errMsg "This script uses GNU-PARALLEL to launch in parallel a series of InterGenic Region processes" || echo "Using $GNUPARALLEL"

# set location of RACS
RACSloc=$SCRATCH"/REPO/core/"
interGenic=$RACSloc"/intergenic/det-interGenes.sh"

# select reference GFF3 file
REFgff3=$SCRATCH"/negCtrl/refs/T_thermophila_June2014.gff3"

# location of ORF results used as input for the IGR script
ORFdirs="ORF_RACS_results-"	#20181212-141459"	#"ORF_RACS_results-"


# function to explore directories with RACS ORF results
processFiles() {
	for i in $ORFdirs*; do
		cd $i; #pwd; #echo FINAL.table.*1;
		# generate list of sample files per directory
		ls -1 *fastq.gz-sorted.bam > sample.input
		### check the actual alingment and final.table files are there...
		alnFiles=$(cat sample.input | grep -o -P '(?<=aln).*(?=.fastq.gz-sorted.bam)' | sed 's/ /-/')
		IGRtable="FINAL.table."$alnFiles
		#echo "expected files to process..." $alnFiles $IGRtable
		###
		execute=$(for IGRtable in FINAL.table*1; do	\
			echo	$interGenic  $IGRtable $REFgff3 tableIGR--$IGRtable sample.input ;
			done)
		echo "echo $i &&  cd $i &&      pwd     &&	$execute   && 	cd .. ";
		cd ..
	done
}

# specify name of the file were to record the log of the jobs
LOG=$USER-IGR_RACS-`date '+%Y%m%d-%H%M%S'`.log

# number of tasks to run at the same time, ideally it could be equal to 
#he number of processors (or twice if hyper-threading is availble)
cores=$(grep -P '^core id\t' /proc/cpuinfo| wc -l) 
PARALLEL_TASKS_PER_NODE=$cores

# process all the jobs via GNU-PARALLEL
processFiles  | $GNUPARALLEL --joblog $LOG  -j $PARALLEL_TASKS_PER_NODE 
