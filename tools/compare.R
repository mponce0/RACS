#########################################################################
# RACS: Comparison Tools
#
# RACS utilities for comparison with MACS2 results
#
#  *********************************************************************
#  * * *  PLEASE NOTICE THAT THIS TOOL IS STILL UNDER DEVELOPMENT  * * *
#  *********************************************************************
#
# HOW TO USE this script:
#
# 1) start by checking that the needed R packages are installed in your system:
#	Rscript PATHtoRACSrepo/tools/setup.R
#
# 2) launch and R session and load the tool:
#	source("PATHtoRACSrepo/tools/compare.R")
#
#    now, several functions should be available for you to use, including some
#    tests cases; eg.
#
#
########################################################################
#
#
# Function to establish the location of the script... hence the relative path to the utilities file
# this function needs to be in the main driver script!
#


#########################################################################

# function to load data from a spreadsheet format
load.data <- function(filename,spix=1) {

	# 1st check that the file exist
	checkFile <- function(filename) {
		while (!file.exists(filename)) {
			cat(paste(filename,"not found!",'\n'))
			cat("Please select a file")
			filename <- file.choose()
		}
		return(filename)
	}

	# check that the XLSX package is available and load it
	loadCheckPkg("xlsx")

	cat(paste("Loading file",filename,'\n'))
	filename <- checkFile(filename)

	# reading data
	sample <- read.xlsx(filename,spix)
	return(sample)
}


# function to check whether a package is available in the system
loadCheckPkg <- function(pckgs){
	fail = FALSE
	for (pckg in pckgs) {
		# check whether the package is NOT loaded
		if (! paste('package:',pckg,sep="") %in% search()) {
			# check whether the package is avaialble in the system
			if (pckg %in%  .packages(all.available = TRUE)) {
				# load the package
				cat("Loading library",pckg,"... \n")
				library(pckg, character.only=TRUE)
			} else {
				msg <- paste("Package:",pckg, "not found! This package is needed for this script to work.",'\n',"You need to install this package using ",paste("install.package('",pckg,"')",sep=""))
				cat(msg)
				fail = TRUE
			} 
		}
	}

	if (fail) stop("Some required packages are missing!")
}

#######


### TESTS CASES
sample1 <- load.data("BD1_peaks.xlsx",1)
sample2 <- load.data("BD1_peaks_MACS2.xlsx",1)


# ACTUAL DATA
sampleIBD1 <- read.csv("Ibd1-2.csv",sep='\t')
sampleIBD2 <- read.csv("Ibd2-2.csv",sep='\t')

macsIBD1 <- load.data("BD1_peaks_MACS2.xlsx",1)
macsIBD2 <- load.data("BD2_peaks_MACS2.xlsx",1)

## IBD1/2 cases
ibdX <- function(sample,ref,filename="ibdX.pdf") {
  ibdX <- comparison(sample,ref,FALSE)
  pdf(file=filename)
  vizDiffs(ibdX)
  dev.off()
}
#####

tests <- function() {
	sample1 <- data.frame()
	sample1 <- rbind(sample1, c(as.character("scfld_01"), as.numeric(1),as.numeric(101)) )

}

#######

# MAIN fucntions of the comparison tool

overlap <- function(x1,x2, y1,y2){
   # NO overlap condition
   if (x1 > y2) return(+1.0)
   if (x2 < y1) return(-1.0)

   ax = (x2 - x1)
   ay = (y2 - y1)
   #print(ax)
   #print(ay)

   #if ((x1<=y1) & (x2>=y2)) return(+ax/ay)
   if (x1<=y1) return(+ax/ay)
   #if ((x1>y1) & (x2<y2)) return(-ay/ax)
   if (x1>y1) return(-ay/ax)
   if ((x1==y1)&(x2==y2)) return(0)

   return(NA)
}

######

comparison.ALL <- function(sample1,sample2) {

  # identify scaffolds
  scflds_smpl1 <- unique(as.character(sample1$Region))
  scflds_smpl2 <- unique(as.character(sample2$Region))

  ### 1-to-1 comparison
  results <- data.frame()
  for (scfld in scflds_smpl1) {
  #scfld <- scflds_smpl1[1]
    print(scfld)
    # define subsets based on the scalfold to work with
    sset1 <- sample1[sample1$Region == scfld,]
    sset2 <- sample2[sample2$Region == scfld,]
    # order to subsets per intervals
    sset1 <- sset1[order(sset1$start),]
    sset2 <- sset2[order(sset2$start),]

    for (i1 in 1:dim(sset1)[1]){
        for (i2 in 1:dim(sset2)[1]) {
            ovrlap <- overlap(sset1$start[i1],sset1$end[i1], sset2$start[i2], sset2$end[i2])
            if (is.numeric(ovrlap)) {
		cat(i1,i2,'\n')
		print(ovrlap)
		results <- rbind(results,c(scfld,sset1$start[i1],sset1$end[i1],sset2$start[i2], sset2$end[i2], ovrlap))
	    }
        }
     }
  }
  colnames(results) <- c("scfld","x1","x2","y1","y2","overlap")
  results[abs(results$overlap) != 1,]
  return(results)
}

########

comparison <- function(sample1,sample2, DBG=TRUE) {

  # sort samples per scafold
  sample1 <- sample1[order(sample1$Region),]
  sample2 <- sample2[order(sample2$Region),]

  # identify scaffolds
  scflds_smpl1 <- unique(as.character(sample1$Region))
  scflds_smpl2 <- unique(as.character(sample2$Region))
  scflds <- c(scflds_smpl1,scflds_smpl2)
  scflds <- unique(scflds[order(scflds)])

  ### 1-to-region comparison
  results <- c()
  for (scfld in scflds_smpl1) {
#  for (scfld in scflds) {
  #scfld <- scflds_smpl1[1]
    print(scfld)
    # define subsets based on the scalfold to work with
    sset1 <- sample1[sample1$Region == scfld,]
    sset2 <- sample2[sample2$Region == scfld,]
    # order to subsets per intervals
    sset1 <- sset1[order(sset1$start),]
    sset2 <- sset2[order(sset2$start),]
    dsset1 <- dim(sset1)[1]
    dsset2 <- dim(sset2)[1]

    if (dsset1 == 0) {
	if (DBG) {
	# not data registered for this scaffold in sample1
	cat("not data registered for this scaffold:",scfld," in sample1",'\n')
	print(sset1)
	print(sset2)
        }
	tmpreg <-  c(as.character(scfld),"--","--", sset2$start,sset2$end, as.numeric(-1))
	if (DBG) print(tmpreg)
        results <- rbind(results, as.character(tmpreg))
    } else if (dsset2 == 0 ) {
        if (DBG) {
	cat("not data registered for this scaffold:",scfld," in sample2",'\n')
        print(sset1)
        print(sset2)
        }
        tmpreg <-  c(as.character(scfld),"--","--", sset1$start,sset1$end, as.numeric(+1))
        if (DBG) print(tmpreg)
        results <- rbind(results, as.character(tmpreg))
    } else {
    for (i1 in 1:dsset1){
        regResults <- c()
        for (i2 in 1:dsset2) {
            ovrlap <- overlap(sset1$start[i1],sset1$end[i1], sset2$start[i2], sset2$end[i2])
            if (!is.na(ovrlap)) {
                cat(scfld,i1,i2,"---",sset1$start[i1],sset1$end[i1], sset2$start[i2], sset2$end[i2],'\n')
                print(ovrlap)
                newRecord <-  c(as.character(scfld),as.numeric(sset1$start[i1]),as.numeric(sset1$end[i1]),as.numeric(sset2$start[i2]), as.numeric(sset2$end[i2]), as.numeric(ovrlap))
		if (DBG) print(paste("<<<<<<",newRecord))
		regResults <- rbind(regResults, as.character(newRecord))
		#regResults <- rbind(regResults,  c(as.character(scfld),as.numeric(sset1$start[i1]),as.numeric(sset1$end[i1]),as.numeric(sset2$start[i2]), as.numeric(sset2$end[i2]), as.numeric(ovrlap)) )
            }
        }
        #regResults <- cbind(scfld,regResults)
        colnames(regResults) <- c("scafold","x1","x2","y1","y2","overlap")
	regResults <- as.data.frame(regResults)
	filterCond <- abs(as.numeric(as.character(regResults[!is.na(regResults$overlap),]$overlap)))
        if ( dim(regResults[filterCond == 1,])[1] == dsset2 ) {
           # not match at all
           results <- rbind(results, c(as.character(scfld),sset1$start[i1],sset1$end[i1], "--","--", as.numeric(as.character(regResults$overlap[1]))))
        } else {
		##results <- rbind(results, regResults[abs(regResults$overlap) != 1, ])
		#results <- rbind(results, regResults[filterCond != 1,])
		matchingRegs <- regResults[filterCond != 1,]
		if (DBG) { cat("######"); print(matchingRegs) ; print(dim(matchingRegs))}
                #####if (dim(matchingRegs)[1] > 1) stop()
		for (k in 1:dim(matchingRegs)[1]) {
                    krecord <- matchingRegs[k,]
		    newMatchingReg <- c(as.character(krecord$scafold),as.character(krecord$x1),as.character(krecord$x2),as.character(krecord$y1),as.character(krecord$y2),as.character(krecord$overlap))
		    if (DBG) { cat("###### ::: k   ... "); print(newMatchingReg) }
		#######results <- rbind(results, c(as.character(matchingRegs$scafold),as.character(matchingRegs$x1),as.character(matchingRegs$x2),as.character(matchingRegs$y1),as.character(matchingRegs$y2),as.character(matchingRegs$overlap)) )
		#results <- rbind(results, c(as.character(scfld),sset1$start[i1],sset1$end[i1],sset2$start[i2], sset2$end[i2],as.numeric(as.character(matchingRegs$overlap))) )
		    results <- rbind(results,as.character(newMatchingReg))
                }
        }
     }
  }
  }
  colnames(results) <- c("scafold","x1","x2","y1","y2","overlap")
  rownames(results) <- c()
  results <- as.data.frame(results)
  results$overlap <- as.numeric(as.character(results$overlap))
  results[abs(results$overlap) != 1,]

  return(results)
}

######

vizDiffs <- function(results, filename="", threshold=1000, iplots=FALSE) {
	res <- results[!is.na(results$overlap),]
	res <- res[res$overlap<threshold,]
	yvar <- res$overlap

	# Determine max/min in plots
	mmin <- round(min(yvar))
	mmax <- round(max(yvar))
        mm <- max(abs(mmin),abs(mmax))
	yrange <- c(-mm,+mm)
	xrange <- c(1, length(yvar))

	# interactive plot
	if (iplots) {
		loadCheckPkg("plotly")
		#loadCheckPkg("pandoc")
		p1 <- plot_ly(x = c(results$scafold), y = results$overlap, type="bar")
		p2 <- plot_ly(y = results$overlap, group=results$scafold, type="bar")
		p3 <- plot_ly(x=~results$scafold, y = results$overlap, group=results$scafold, type="bar")

		htmlwidgets::saveWidget(as.widget(p1), paste(filename,"-p1.html"), selfcontained=FALSE)
		htmlwidgets::saveWidget(as.widget(p2), paste(filename,"-p2.html"), selfcontained=FALSE)
		htmlwidgets::saveWidget(as.widget(p3), paste(filename,"-p3.html"), selfcontained=FALSE)
	}

	# static plots
	if (filename!="") pdf(file=filename)
	if (filename=="") dev.new()
	plot(res$scafold,yvar)
	abline(h = 0, v = 0, col = "gray60")

	if (filename=="") dev.new()
	#par(mfrow=c(2,1))
	barplot(res$overlap, ylim=yrange)
	box()
	par(new=T)
	plot(yvar, cex=0.5, ylim=yrange, ann=F, axes=F)
	abline(h = 0, v = 0, col = "gray60")

	if (filename=="") dev.new()
	par(mfrow=c(2,1))
	plot(res$overlap, cex=0.5, xlim=xrange, ylim=yrange, type='b')
	abline(h = 0, v = 0, col = "gray60")
	#par(new=TRUE)
	plot(which(res$overlap>0), res[res$overlap>0,]$overlap, cex=.5, col='blue', xlim=xrange, ylim=yrange)
	par(new=TRUE)
	plot(which(res$overlap<0), res[res$overlap<0,]$overlap, cex=.5, col='red', xlim=xrange, ylim=yrange)
	abline(h = 0, v = 0, col = "gray60")


        if (filename=="") dev.new()
	par(mfrow=c(1,1))
	g <- yvar
	h <- hist(g, freq=TRUE, breaks = 75, xlim=c(-50,50), density = 40, col = " lightgray"  , xlab = "overlap", main = "RACS vs MACS")
	xfit <- seq(min(g), max(g), length = length(g))
	yfit <- dnorm(xfit, mean = mean(g), sd = sd(g))
	yfit <- yfit * diff(h$mids[1:2]) * length(g)
	lines(xfit, yfit, col = "black", lwd = 2)
	text(0,max(yfit*1.10),paste("mean=",mean(g), " -- ", "sd=",sd(g)))

	if (filename!="") dev.off()
}

######
