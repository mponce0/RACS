#!/bin/bash -l
##SBATCH -p debug
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH -t 1:00:00
#SBATCH -J RACS_negative_control
#SBATCH --mail-user=YOURemailHERE
#SBATCH --mail-type=ALL

# load definitions from some environment variables to generalize the submission script,
# such as:  RACS location, datafiles location, RAMdisk, ...
. setup.env

# load needed modules // RACS repository located on $SCRATCH
. $RACS/hpc/modules

echo $SLURM_SUBMIT_DIR
cd $SLURM_SUBMIT_DIR


date

# RACS repo located on $SCRATCH
# data subdirectory containing data files: INPUT and IP files
# refs subdirectory containing reference files: fasta and gff3 files
# the pipeline will attempt to use RAMDisk (/dev/shm) and autodetect maximum number of cores to use
($RACS/core/countReads.sh        \
        $DATA/SSCH1-1_Input_S2_R1_001.fastq.gz  $DATA/SSCH1-1_ChIP_S1_R1_001.fastq.gz       \
        $REFS/T_thermophila_June2014_assembly.fasta  $REFS/T_thermophila_June2014.gff3  $RAMDISK  \
        >& output.log;	\
echo $?;	\
date) &

wait
