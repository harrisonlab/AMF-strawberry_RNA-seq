#!/bin/bash

SCRIPT_DIR=$(readlink -f ${0%/*})
#FORWARD=$1
#OUT=$2

#qsub -l h=blacklace11 $SCRIPT_DIR/submit_assemble.sh $SCRIPT_DIR $FORWARD $OUT

qsub -l h=blacklace11 $SCRIPT_DIR/submit_assemble.sh $SCRIPT_DIR $@