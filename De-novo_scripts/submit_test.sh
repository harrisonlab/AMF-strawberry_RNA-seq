#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=4G

SCRIPT_DIR=$1
shift
FORWARD=$1
shift
REVERSE=$1
shift
OUTDIR=$1
shift
ADAPTERS=$1
shift
MINL=$1
shift
MAXDIFF=$1
shift
QUAL=$1
shift

LABEL=$( echo $FORWARD|awk -F"\t" '{print $NF}')

mkdir -p $OUTDIR 
cd $OUTDIR 

usearch9 -fastq_mergepairs $FORWARD -reverse $REVERSE -fastqout ${LABEL}.t1  -fastq_maxdiffpct $MAXDIFF -fastq_maxdiffs $(($MINL*${MAXDIFF}/100)) -fastq_minlen $MINL -fastq_merge_maxee $QUAL 
usearch9 -search_oligodb ${LABEL}.t1 -db $ADAPTERS -strand both -userout ${LABEL}.t1.txt -userfields query+target+qstrand+diffs+tlo+thi+trowdots 

awk -F"\t" '{print $1}' ${LABEL}.t1.txt|sort|uniq|$SCRIPT_DIR/adapt_delete.pl ${LABEL}.t1 > ${LABEL}.joined.fq

rm ${LABEL}.t1.txt ${LABEL}.t1
