# table.sh file, part of RACS ORF pipeline
# this script is internal to the RACS ORF pipeline, and it is called from countReads.sh

# command-line arguments
FILE=$1
# eg. FILE=T_thermophila_June2014.gff3


#####################################################################
#####################################################################
## The following two sections:
##
##		"FILTERS AND DELIMITERS"
##
##	and
##
##		"SELECTIONS"
##
## should be determine depending on the particular organism, protein,
## genes (ie. target) and data layout of the specific file to be
## processed.
##
## Here we present the case for Tetrahymena Thermophila.
#####################################################################
#####################################################################


############  CASE FOR TETRAHYMENA THERMOPHILA  #####################
################# FILTERS AND DELIMITERS ############################
# filterS can be modified/added depending on the "TARGET" organism and 'protein'
filter1="gene"
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

######################################################################



################## selection ... #####################################

# grab scafold and genes' range
grep $filter1 $FILE | grep $filter2 | awk '{print $1" "$4"-"$5}' > tmp0.$FILE

# grab "TTHERM", ie. *delim1*
# grep $filter1 $FILE | grep $filter2 | awk 'BEGIN{FS="TTHERM"} {print $2}' | awk	'BEGIN{FS=";Note"} {print "TTHERM"$1}' > tmp1.$FILE
grep $filter1 $FILE | grep $filter2 | awk  -v d1="$delim1" 'BEGIN{FS=d1} {print $2}' | awk -v d1="$delim1" -v d2="$delim2" 'BEGIN{FS=d2} {print d1$1}' > tmp1.$FILE

# grab 'Note' and replace 'spaces' with 'underscores (_)'
#grep $filter1 $FILE | grep $filter2 | awk 'BEGIN{FS="Note="} {print "Note="$2}' | sed 's/ /_/g' > tmp2.$FILE
grep $filter1 $FILE | grep $filter2 | awk -v d3="$delim3" 'BEGIN{FS=d3} {print d3$2}' | sed 's/ /_/g' > tmp2.$FILE

# compute gene size
grep $filter1 $FILE | grep $filter2 | awk '{print $5-$4+1}' > tmp3.$FILE

#######################################################################

# join sliced data (tmp.files) to generate a combined table
#paste tmp0 tmp1 tmp2 tmp3
paste tmp0.$FILE tmp1.$FILE tmp2.$FILE tmp3.$FILE | sort  -k 1 | sort -t: -n -k 2  | awk '{print $1":"$2"\t"$3"\t"$4"\t"$5"\t"$6}' > table.$FILE

# cleanup: remove temporary files...
#rm tmp0 tmp1 tmp2 tmp3
rm -v tmp?.$FILE


#######################################################################
#######################################################################
