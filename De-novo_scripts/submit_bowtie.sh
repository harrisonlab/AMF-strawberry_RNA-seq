#!/bin/bash

#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

REF=$1
shift
OUTDIR=$1
shift
FORWARD=$1
shift
REVERSE=$1

TEMPF=FILTERED_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1)
TEMPR=FILTERED_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1)


bowtie2 --no-unal -x $REF -f -U $FORWARD -S /dev/null --un $OUTDIR/$TEMPF.fa 
bowtie2 --no-unal -x $REF -f -U $REVERSE -S /dev/null --un $OUTDIR/$TEMPR.fa 


grep ">" $OUTDIR/$TEMPF.fa > $OUTDIR/$TEMPF.fa.l1
grep ">" $OUTDIR/$TEMPR.fa >> $OUTDIR/$TEMPF.fa.l1


sort $OUTDIR/$TEMPF.fa.l1|uniq -d > $OUTDIR/$TEMPF.fa.l2
sed -i -e 's/>//' $OUTDIR/$TEMPF.fa.l2


F=$(echo $FORWARD|awk -F"/" '{print $NF}')
R=$(echo $REVERSE|awk -F"/" '{print $NF}')

usearch9  -fastx_getseqs $OUTDIR/$TEMPF.fa -labels $OUTDIR/$TEMPF.fa.l2 -fastaout $OUTDIR/${F}.f.cleaned_filtered.fa

usearch9  -fastx_getseqs $OUTDIR/$TEMPR.fa -labels $OUTDIR/$TEMPF.fa.l2 -fastaout $OUTDIR/${R}.r.cleaned_filtered.fa

rm $OUTDIR/$TEMPF.fa $OUTDIR/$TEMPR.fa $OUTDIR/$TEMPF.fa.l1 $OUTDIR/$TEMPF.fa.l2

