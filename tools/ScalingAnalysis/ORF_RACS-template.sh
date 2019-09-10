#!/bin/bash
#
# Shell script template that can be used for running the ORF-RACS pipeline in a
# set of different experiments.
#
# This script will run the RACS scripts in background, which is achieved by
# including the "&" symbol at the end of each call to the RACS script.

cores=${1:-"1"}

# define location of the RACS pipeline and script to run, in this case "countReads.sh"
RACSscript="$HOME/RESEARCH/racs/core/countReads.sh"

# define location of data and reference files
dataDIR="$SCRATCH/TT/DATA/data1_BD1-2"
refsDIR="$SCRATCH/GPC/scratch2/Tetrahymena_Ryerson/REFS"

# specify reference and annotation files
refsFILE="T_thermophila_June2014.gff3"
fastaFILE="T_thermophila_June2014_assembly.fasta"

workingDIR="/dev/shm"

# start tracer...
. $HOME/RESEARCH/STATS/tracer.sh "du -s $workingDIR/$USER" &
trPID=$!

# run pipeline
$RACSscript	\
	$dataDIR/BD1_INPUT.fastq.gz	\
	$dataDIR/BD1_IP.fastq.gz	\
	$refsDIR/$fastaFILE  $refsDIR/$refsFILE	\
	$workingDIR	\
	$cores	

#wait

# terminate tracer...
kill -9 $trPID
#pkill watch
