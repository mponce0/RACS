#!/bin/bash

# reverse order -- to run first tests faster
#cores="32 16 8 4 2  1"
cores="1 2 4 8 16 32 64"

for i in $cores; do
	dir=${i}"cores";
	echo $i ... $dir;
	mkdir $dir; cd $dir;
	echo "processing... `pwd`";
	. ../ORF_RACS-template.sh $i ;  #>  /dev/null 2>&1 ;
	cd ..;
done

./checkResults.sh
