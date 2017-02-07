#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=120G

OUTPUT=$1
shift

mkdir -p $OUTPUT

$SGE_O_HOME/trinity/util/insilico_read_normalization.pl --output $TMP $@

cd $TMP
cp * $OUTPUT/.
cd $OUTPUT
