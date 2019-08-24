#!/bin/bash
#
# Shell script template that can be used for running the ORF-RACS pipeline in a
# set of different experiments.
#
# This script will run the RACS scripts in background, which is achieved by
# including the "&" symbol at the end of each call to the RACS script.


# define location of the RACS pipeline and script to run, in this case "countReads.sh"
RACSscript="PATHtoRACS/core/countReads.sh"

# define location of data and reference files
dataDIR="PATHtoDATA/ExperimentA/run1"
refsDIR="PATHtoREFS/"

# specify reference and annotation files
refsFILE="organismREFfile.gff3"
fastaFILE="organismANNOTATIONfile_assembly.fasta"


# run pipeline
$RACSscript	\
	# ChIP file
	$dataDIR/ExperimentA_1_prot1-1_INPUT_S1_R1_001.fastq.gz	\
	# INPUT file
	$dataDIR/ExperimentA_2_prot1-1_ChIP_S2_R1_001.fastq.gz	\
	# reference files
	$fastaFILE  $refsDIR/$refsFILE	\
	# working space
	/dev/shm  &

$RACSscript	\
	$dataDIR/ExperimentA_INPUT_S2_R1.fastq.gz	\
	$dataDIR/ExperimentA_ChIP_S2_R1.fastq.gz	\
	$fastaFILE  $refsDIR/$refsFILE	\
	/scratch1/mponce/  &

# . . .

