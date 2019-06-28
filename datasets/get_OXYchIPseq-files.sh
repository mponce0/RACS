#!/bin/bash

# Tool for download Oxytrichia data from NCBI_SRA
# This script is part of
# RACS v1.0 (2018/2019) -- Open source tools for Analizing ChIP-Seq data                                   

# It requires the "NCBI SRA (Sequence Read Archive)" to download the data
# whcioh can be obtained from	https://github.com/ncbi/sra-tools

# set PATH to add "SRA toolkit"
PATH=$PATH:/scratch1/mponce/RESEARCH/Tetrahymena_Ryerson/TOOLS/NCBI_SRA_toolkit/sratoolkit.2.9.6-1-ubuntu64/bin

#######################################################
# check that the script is not being sourced!!!
if [[ $0 == '-bash' ]]; then
        echo "Please do not 'source' this script; ie. run it as PATHtoRACS/core/SCRIPTname arguments"
        return 1
fi

# setting preamble, detecting scripts location
scriptsDIR=`dirname $0`


# load auxiliary fns for integrity checks and message/error handling
if [[ -f $scriptsDIR/../core/auxs/auxFns.sh ]]; then
        . $scriptsDIR/../core/auxs/auxFns.sh --source-only;
else
        echo "Error auxiliary file: " $scriptsDIR/auxs/auxFns.sh "NOT found!"
        return 11
fi
#######################################################

checkTools fastq-dump gzip

# Oxytricha files:
srxFiles="SRX483016 SRX483017"

# download fastq files
for i in $srxFiles; do
	fastq-dump -I --split-files $i
done

# generate fastq.gz files
for i in *fastq; do
	echo $i ;
	gzip -c $i > $i.gz ;
done

