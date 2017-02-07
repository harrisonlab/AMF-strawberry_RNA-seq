#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=8G

FORWARD=$1
shift
REVERSE=$1
shift
OUTDIR=$1
shift
MAXDIFF=$1
shift
MINL=$1
shift
QUAL=$1
shift

OUTFILE=$(echo $FORWARD|awk -F"/" '{print $NF}')

mkdir -p $OUTDIR 
cd $OUTDIR 

usearch9 -fastq_mergepairs $FORWARD \
	-reverse $REVERSE \
	-fastaout ${OUTFILE}.t1 \
	-fastqout_notmerged_fwd ${OUTFILE}.t2 \
	-fastqout_notmerged_rev ${OUTFILE}.t3 \
	-fastq_maxdiffpct $MAXDIFF \
	-fastq_maxdiffs $(($MINL*${MAXDIFF}/100)) \
	-fastq_minlen $MINL \
	-fastq_merge_maxee $QUAL

QUAL2=$( echo|awk -v num="$QUAL" '{print num*2}' )
MINL2=$( echo|awk -v num="$MINL" '{print num*(2/3)}' )


usearch9  -fastq_filter ${OUTFILE}.t2 \
	-fastq_maxee $QUAL2 \
	-fastq_minlen $MINL2 \
	-fastaout ${OUTFILE}.t4

usearch9  -fastq_filter ${OUTFILE}.t3 \
	-fastq_maxee $QUAL2 \
	-fastq_minlen $MINL2 \
	-fastaout ${OUTFILE}.t5

usearch9  -fastx_revcomp ${OUTFILE}.t5 -fastaout ${OUTFILE}.t6

cat ${OUTFILE}.t1 ${OUTFILE}.t4 ${OUTFILE}.t6 > ${OUTFILE}.joined.fa

rm ${OUTFILE}.t1 ${OUTFILE}.t2 ${OUTFILE}.t3 ${OUTFILE}.t4 ${OUTFILE}.t5 ${OUTFILE}.t6
