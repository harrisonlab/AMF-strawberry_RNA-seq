#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=320G


SCRIPT_DIR=$1
shift
#FORWARD=$1
#shift
#OUT=$1
#shift

#mkdir -p $OUTDIR

$HOME/trinity/Trinity --grid_conf $SCRIPT_DIR/SGE.conf $@ 

#cd $TMP
#cp *.fasta $OUTDIR/.
#cd $OUTDIR


#/home/deakig/trinity/Trinity --grid_conf $SCRIPT_DIR/SGE.conf --seqType fa --CPU 24 --max_memory 32G --single $FORWARD --output $OUT

#/home/deakig/trinity/Trinity --grid_conf /home/deakig/projects/ab_virome/scripts/SGE.conf --seqType fq --CPU 20 --max_memory 16G --normalize_reads --single $FORWARD --output $OUT