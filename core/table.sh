# table.sh file, part of RACS ORF pipeline
# this script is internal to the RACS ORF pipeline, and it is called from countReads.sh

# command-line arguments
FILE=$1
# eg. FILE=T_thermophila_June2014.gff3

# filterS can be modified/added depending on the "TARGET" organism and 'protein'
filter1=gene
filter2="Name=TTHERM_"
# and one could keep addingg further 'filters' if needed...
# filter3='"hypothetical protein"'
# ...

# Eg. 
# TARGET=$(grep $filter1 $FILE | grep $filter2)
#
# grep $filter1 $FILE | grep $filter2 | awk '{print $1":"$4"-"$5"  "$9}


# define some delimiters...
delim1="TTHERM"
delim2=";Note"
delim3="Note="


################## selection ... #####################################

# grab scafold and genes' range
grep $filter1 $FILE | grep $filter2 | awk '{print $1" "$4"-"$5}' > tmp0
# grab "TTHERM"
grep $filter1 $FILE | grep $filter2 | awk 'BEGIN{FS="TTHERM"} {print $2}' | awk 'BEGIN{FS=";Note"} {print "TTHERM"$1}' > tmp1
# grab 'Note' and replace 'spaces' with 'underscores (_)'
grep $filter1 $FILE | grep $filter2 | awk 'BEGIN{FS="Note="} {print "Note="$2}' | sed 's/ /_/g' > tmp2
# compute gene size
grep $filter1 $FILE | grep $filter2 | awk '{print $5-$4+1}' > tmp3

#######################################################################

# join sliced data (tmp.files) to generate a combined table
paste tmp0 tmp1 tmp2 tmp3 | sort  -k 1 | sort -t: -n -k 2  | awk '{print $1":"$2"\t"$3"\t"$4"\t"$5"\t"$6}' > table.$FILE

# cleanup: remove temporary files...
rm tmp0 tmp1 tmp2 tmp3

