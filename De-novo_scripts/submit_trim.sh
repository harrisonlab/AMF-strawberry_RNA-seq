#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

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
THREADS=${1:-4}
shift

mkdir -p $OUTDIR

FO=$( echo $FORWARD|awk -F"/" '{print $NF}' )
RO=$( echo $REVERSE|awk -F"/" '{print $NF}' )

java -jar $SCRIPT_DIR/trimmomatic-0.33.jar PE -threads $THREADS -phred33 $FORWARD $REVERSE $OUTDIR/$FO.trimmed.fq /dev/null $OUTDIR/$RO.trimmed.fq /dev/null ILLUMINACLIP:$ADAPTERS:2:20:7 $@

