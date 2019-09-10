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
		fi
	done;
done

echo $target

echo "Number of Tests Passed: $nbrPassedTests"
echo "Number of Checks Failed: $nbrFailedTests"
echo "Total Number of files compared: $nbrTests"
