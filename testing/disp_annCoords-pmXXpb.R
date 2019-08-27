
##########################################################################
#
# This script can be used for *upstream/downstream* analysis of reads in
# ChIP-Seq data utilizing the RACS pipeline.
# If upstream/downstream considerations have to be done when analyising
# ChIP-Seq data, this script will allow the user to offset the annotation
# file by an specif number of pair-bases.
# Then the usual methods implemented in the RACS pipeline can be used as usual
# to study the data in reference to the modified annotation file, effectively
# resulting in the comparison of "wider"/"slimer" regions in relationship to the
# original annotation file.
# Another way to describe this in terms of a relative change of coordinates,
# instead of changing the coordinates of the ChIP/INPUT files, the
# corresponding anotation is file is coordinates-'shifted'.
#
# This script is part of
#        RACS v1.0 (2018/2019) -- Open source tools for Rapid Analisys of ChIP-Seq data         
#
#
# Usage:
#	Rscript modif_TT-pmXXpb.R  N  [refTable]
#
# where N is the number of pair-bases to shift the reference table
# and 'refTable' is the filename of the annotation file, if this argument is
# not specified the annotation file for the T.thermophila will be assumed.
#
###########


usage <- function() {
	cat("How to use this script: \n")
	cat(" Rscript modif_TT-pmXXpb.R  N [refTable] \n \n")

	cat(" where N is the number of pb to shift the ref. table \n")
	cat(' "refTable" is the filename of the annotation file, if not specified we will assume the T.Thermophila one, ie. "T_thermophila_June2014.gff3"')
	stop("please try again!")
}

error <- function(msg) {
	cat(msg,'\n')
	usage()
}


# read command line arguments
args <- commandArgs(trailingOnly=T)
NbrArgs <- length(args)

if (NbrArgs < 1) error("This script requires at least one argument")
if (NbrArgs > 2) error("This script uses upto 2 arguments!")

# determine number of pb to offset the ranges...
# 1st check that is a number indeed
if (is.na(as.numeric(args[1]))) {
	error("The first argument should be a possitive number representing the pb offset to apply to the ref. file!")
} else {
	pb <- as.numeric(args[1])

	# check that is a positive number!
	if (pb<0) error("The first argument should be a possitive number representing the pb offset to apply to the ref. file!")
}

cat("Offset: ",pb,'\n')

# check that the second argument is an existent file
if (file.exists(args[2])) {
	refTable <- args[2]
} else {
	defRef <- "T_thermophila_June2014.gff3" 
	cat("Ref. file not specified or not found...",'\n')
	cat(" assuming 'Tetrahymena Thermophila' ref. file: ",defRef,'\n')
	refTable <- defRef
}

# read ref. file...
cat(" . reading ref. table ", refTable, '\n')
# check that ref.file exists...
if (file.exists(refTable)) {
	TT <- read.csv(refTable, sep='\t', header=F)
} else {
	error(paste(refTable,"NOT found!"))
}



###
# offset regions...
cat(" .. offsetting regions...",'\n')

## "upstream"
# take care of the limits at the beggining...
# ie. check for cases where the beggining of the region is smaller than the offset...
to1 <- TT$V4<=pb
# set such cases to 1
TT[to1,]$V4 <- 1
# and the rest to the propper offset
TT[!to1,]$V4 <- TT[!to1,]$V4-pb

## "downstream"
# define key for  the whole scaffold
scfldID <- "supercontig"
# obtain a new dataframe for each scaffold with begginings and *ends*
scflds <- data.frame(TT[TT$V3==scfldID,]$V1, TT[TT$V3==scfldID,]$V4, TT[TT$V3==scfldID,]$V5)
names(scflds) <- c("V1", "V4", "V5") 
# go over each entry...
lowerLim <- 1
upperLim <- dim(TT)[1]
toEnd <- 0
for (scfl in lowerLim:upperLim) {
	# check that the record is not the scaffold information given by the 'scfldID' keyword, eg. "supercontig"
	if (TT[scfl,]$V3 != scfldID) {
		# look for the maximum of the scaffold
		maxScfld <- scflds[scflds$V1 == TT[scfl,]$V1,]$V5
		# assign either ending+pb OR max.scaffold to the ending of the region
		#cat(maxScfld, TT[scfl,]$V5 , min(TT[scfl,]$V5+pb, maxScfld) )
		#cat("\n")
		TT[scfl,]$V5 <- min(TT[scfl,]$V5+pb, maxScfld)
		if (TT[scfl,]$V5== maxScfld) toEnd <- toEnd+1
	} else {
		cat(" +--> at scaffold", as.character(TT$V1)[scfl], paste("(",scfl,"/",upperLim,")", sep=''), '\n')
	}
}
###

# some stats to print out
cat("elements shifted to the beggining of the region ", length(to1), '\n')
cat("elements topped at the end of the region: ", toEnd, '\n')

# save file...
outputFile <- paste(refTable,'__',pb,"pb", sep='')
cat(" ... saving file into:",outputFile,'\n')
write.table(TT,file=outputFile, sep='\t', quote=FALSE, col.names=FALSE, row.names=FALSE)


#########
