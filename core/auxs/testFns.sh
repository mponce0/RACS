#!/bin/bash 


# unit testing (integrity tests) for the pipeline
#
# script containing a series of integrity checks: internal and external dependencies of the pipeline

# determine where the scripts are located
scriptsDIR=`dirname $0`

# load auxiliary fns
. $scriptsDIR/auxFns.sh --source-only


main() {
	# integrity checks
	echo "*** CHECKING RACS pipeline INTERNAL INTEGRITY..."
	for i in `cat $scriptsDIR/../test/lst`; do
		#echo $i;
		checkIntegrityPipeline	../$i;
	done 

	# external dependencies
	echo "*** CHECKING EXTERNAL DEPENDENCIES with auxiliary software: BWA, SAMTOOLS & RSCRIPT..."
	# checking requirements for the ORF part of the RACS pipeline
	checkTools bwa samtools
	# checking requirements for the intergenic part of the RACS pipeline
	checkTools samtools Rscript
}


if [ "${1}" != "--source-only" ]; then
	main "${@}"
fi

#########
