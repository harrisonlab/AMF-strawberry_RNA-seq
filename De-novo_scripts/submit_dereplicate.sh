#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=8G

SCRIPT_DIR=$1
shift
OUTDIR=$1
shift
FILE=$1
shift


PREFIX=$(echo $FILE|awk -F"/" '{print $NF}')

cd $OUTDIR

#### Dereplication
zcat -f -- $FILE $@|awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'|$SCRIPT_DIR/dereplicate.pl > ${PREFIX}.dereplicated.fasta 


