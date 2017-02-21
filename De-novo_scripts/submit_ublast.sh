#!/bin/bash

#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

REF=$1
shift
OUTDIR=$1
shift

TEMPFILE=FILTERED_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1)

bowtie2 --no-unal -x $REF --un $OUTDIR/$TEMPFILE -S /dev/null -U $@

