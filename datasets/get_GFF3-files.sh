#!/bin/bash

# 
# This script is part of
# RACS v1.0 (2018/2019) -- Open source tools for Analizing ChIP-Seq data     
#
# Shell script provided to obtain dataset for:
#
# Tetrahymena Thermophila
# 	(legacy)
#	GFF3:	http://www.ciliate.org/system/downloads/T_thermophila_June2014.gff3
#	FASTA:	http://www.ciliate.org/system/downloads/T_thermophila_June2014_assembly.fasta
#	(2025)
#	GFF3:	https://tet.ciliate.org/common/downloads/tet/legacy/T_thermophila_June2014.gff3
#	FASTA:	https://tet.ciliate.org/common/downloads/tet/legacy/T_thermophila_June2014_assembly.fasta
#
# and
#
# Oxytricha Trifallax
# 	(legacy)
#	GFF3:	http://oxy.ciliate.org/system/downloads/Oxytricha_trifallax_022112.gff3
#	FASTA:	http://oxy.ciliate.org/system/downloads/Oxytricha_trifallax_022112_assembly.fasta
#	(2025)
#	GFF3:	https://oxy.ciliate.org/common/downloads/oxy/Oxytricha_trifallax_022112.gff3
#	FASTA:	https://oxy.ciliate.org/common/downloads/oxy/Oxytricha_trifallax_022112_assembly.fasta


###
# Tetrahymena Thermophila
TT_gff3_URL="http://www.ciliate.org/system/downloads/T_thermophila_June2014.gff3"
TT_gff3_URL="https://tet.ciliate.org/common/downloads/tet/legacy/T_thermophila_June2014.gff3"
TT_fasta_URL="http://www.ciliate.org/system/downloads/T_thermophila_June2014_assembly.fasta"
TT_fasta_URL="https://tet.ciliate.org/common/downloads/tet/legacy/T_thermophila_June2014_assembly.fasta"

#
# Oxytricha Trifallax
OXY_gff3_URL="http://oxy.ciliate.org/system/downloads/Oxytricha_trifallax_022112.gff3"
OXY_gff3_URL="https://oxy.ciliate.org/common/downloads/oxy/Oxytricha_trifallax_022112.gff3"
OXY_fasta_URL="http://oxy.ciliate.org/system/downloads/Oxytricha_trifallax_022112_assembly.fasta"
OXY_fasta_URL="https://oxy.ciliate.org/common/downloads/oxy/Oxytricha_trifallax_022112_assembly.fasta"
###

# select tool for downloading data...
CMD=`which curl`

if [ -z "$CMD" ]
then
	CMD=`which wget`
else
	CMD=$CMD" -L -O"
fi

echo "using $CMD..."

# Specify datasets for Tetrahymena Thermophila and Oxytrichia ....
datasets=" ${TT_gff3_URL} ${TT_fasta_URL} ${OXY_gff3_URL} ${OXY_fasta_URL} "

# download data...
for i in $datasets; do
	echo $i;
	$CMD $i;
done
