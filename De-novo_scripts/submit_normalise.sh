#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=320G

OUTPUT=$1
shift

mkdir -p $OUTPUT

/home/deakig/trinity/util/insilico_read_normalization.pl --output $TMP $@

cd $TMP
cp * $OUTPUT/.
cd $OUTPUT