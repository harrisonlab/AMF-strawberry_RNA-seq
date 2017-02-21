#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

FORWARD=$1
shift
REVERSE=$1
shift
OUTDIR=$1
shift
QUALF=$1
shift
QUALR=$1
shift

OUTFILE=$(echo $FORWARD|awk -F"/" '{print $NF}')


cd $TMP 
#$OUTDIR 


usearch9  -fastq_filter $FORWARD \
	-fastq_maxns 0 \
	-fastq_minlen 140 \
	-fastq_maxee $QUALF \
	-fastaout ${OUTFILE}.f1

echo "cleaned forward"

usearch9  -fastq_filter $REVERSE \
	-fastq_maxns 0 \
	-fastq_trunclen 140 \
	-fastq_maxee $QUALR \
	-fastaout ${OUTFILE}.r1

echo "cleaned reverse"

cut -d ' ' -f 1 < ${OUTFILE}.f1 > ${OUTFILE}.f2
cut -d ' ' -f 1 < ${OUTFILE}.r1 > ${OUTFILE}.r2

grep ">" ${OUTFILE}.f2 > ${OUTFILE}.l1
grep ">" ${OUTFILE}.r2 >> ${OUTFILE}.l1

echo "created list of cleaned f&r reads"

sort ${OUTFILE}.l1|uniq -d > ${OUTFILE}.l2
sed -i -e 's/>//' ${OUTFILE}.l2

echo "created list of duplicted f&r reads"

usearch9  -fastx_getseqs ${OUTFILE}.f2 -labels ${OUTFILE}.l2 -fastaout ${OUTFILE}.f.filtered.fa
echo "found matching forward reads"

usearch9  -fastx_getseqs ${OUTFILE}.r2 -labels ${OUTFILE}.l2 -fastaout ${OUTFILE}.r.filtered.fa
echo "found matching reverse reads"

rm ${OUTFILE}.f1 ${OUTFILE}.r1 ${OUTFILE}.f2 ${OUTFILE}.r2 ${OUTFILE}.l1 ${OUTFILE}.l2

mkdir -p $OUTDIR 
cp *  $OUTDIR/.