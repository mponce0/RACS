#!/bin/bash

# script for testing results from scaling analysis
# sanity check for results!

files=`ls -1 *cores/ORF*/FINAL*`

for i in $files; do
	target=`basename $i`
done

dirs=`ls -d *cores/ORF*`

nbrTests=0
nbrFailedTests=0
nbrPassedTests=0

for i in $dirs; do
	for j in $dirs; do
		nbrTests=$((nbrTests+1));
		echo "comparing $i/$target vs $j/$target";
		comparison=$( diff $i/$target $j/$target );
		exit_code=$?;  #echo ${exit_code};
		if [[ $exit_code -eq "0" ]]; then
			echo -e "\t >>> test succesful... "
			nbrPassedTests=$((nbrPassedTests+1))
		else
			echo "***** ERROR !!! when checking results failed at $i/$target VS $j/$target"
			nbrFailedTests=$((nbrFailedTests+1))
			dir1=`dirname $i`
			dir2=`dirname $j`
			datadir=`basename $PWD`
			diffFile="$dir1-$dir2--$datadir.diffs"
			echo "### $diffFile"
			touch $HOME/$diffFile
			echo -e "geneSz.diff \t INPUTs \t IPs \t ratio" >> $HOME/$diffFile
			paste $i/$target $j/$target | awk 'BEGIN{TOL=1e-7} function abs(v) {return v < 0 ? -v : v} {print abs($4-$10) "\t" abs($5-$11) "\t" abs($6-$12) "\t" abs($5/($6+TOL))/(($11/($12+TOL))+TOL) }' >>  $HOME/$diffFile
		fi
	done;
done

echo $target

echo "Number of Tests Passed: $nbrPassedTests"
echo "Number of Checks Failed: $nbrFailedTests"
echo "Total Number of files compared: $nbrTests"
