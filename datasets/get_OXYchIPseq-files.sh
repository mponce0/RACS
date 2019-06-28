#!/bin/bash

# Tool for download Oxytrichia data from NCBI_SRA
# This script is part of
# RACS v1.0 (2018/2019) -- Open source tools for Analizing ChIP-Seq data                                   

# It requires the "NSBI SRA toolkit" to download the data

# set PATH to add "SRA toolkit"
PATH=$PATH:/scratch1/mponce/RESEARCH/Tetrahymena_Ryerson/TOOLS/NCBI_SRA_toolkit/sratoolkit.2.9.6-1-ubuntu64/bin

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

