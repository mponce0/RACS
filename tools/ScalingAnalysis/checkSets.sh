#!/bin/bash

# script to check a set of datasets
# and generate agreggated results

datasets="ibd1 ibd2 med31 med32 oxy"

for i in $datasets; do
	echo $i;
	cd $i; pwd;
	. ../checkResults.sh  | grep ERROR | wc -l;
	cd ..;
done
