#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=8G

REF=$1
shift
PREFIX=$1
shift

STAR --genomeDir $REF --outFileNamePrefix $PREFIX --readFilesIn $@