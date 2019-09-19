#!/bin/bash

# Shell script template for running the IGR-RACS pipeline
#
# This script will run the RACS scripts in background

# generate sample files...
ls -1  alnExperimentA_*1*.bam  alnExperimentA_*2*.bam > sample.12
ls -1  alnExperimentB_*3*.bam  alnExperimentB_*4*.bam > sample.34
ls -1  alnExperimentC_*5*.bam  alnExperimentC_*6*.bam > sample.56
ls -1  alnExperimentD_*7*.bam  alnExperimentD_*8*.bam > sample.78

# define useful environment variables...
REFfile="PATHtoREFS/organismREFfile.gff3"
RACSscript="PATHtoRACS/core/intergenic/det-interGenes.sh"

# run RACS-intergenics
$RACSscript	\
	FINAL.table.ExperimentA_1_prot1-1_INPUT_S1_R1_001-ExperimentA_2_prot1-1_ChIP_S2_R1_001	\
	$REFfile  interGENs_1-2.csv  sample.12	&

$RACSscript	\
	FINAL.table.ExperimentB_3_prot1-2_INPUT_S3_R1_001-ExperimentB_4_prot1-2_ChIP_S4_R1_001	\
	$REFfile  interGENs_3-4.csv  sample.34	&

$RACSscript	\
	FINAL.table.ExperimentC_5_prot2_INPUT_S5_R1_001-ExperimentC_6_prot2_ChIP_S6_R1_001	\
	$REFfile  interGENs_5-6.csv  sample.56	&

$RACSscript	\
	FINAL.table.ExperimentC_7_prot3_INPUT_S7_R1_001-ExperimentD_8_prot3_ChIP_S8_R1_001	\
	$REFfile  interGENs_7-8.csv  sample.78	&
