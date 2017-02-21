#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

FORWARD=$1
shift
REVERSE=$1
shift
OUTDIR=$1

cd $OUTDIR 

OUTFILE=$(echo $FORWARD|awk -F"/" '{print $NF}'|awk -F"_" '{print $1,$4}' OFS="_")

grep ">" $FORWARD > ${OUTFILE}.l1
grep ">" $REVERSE >> ${OUTFILE}.l1
sort ${OUTFILE}.l1|uniq -d > ${OUTFILE}.l2
sed -i -e 's/>//' ${OUTFILE}.l2

usearch9  -fastx_getseqs $FORWARD -labels ${OUTFILE}.l2 -fastaout ${OUTFILE}_F_1.fa
usearch9  -fastx_getseqs $REVERSE -labels ${OUTFILE}.l2 -fastaout ${OUTFILE}_R_2.fa

rm ${OUTFILE}.l1 ${OUTFILE}.l2
 