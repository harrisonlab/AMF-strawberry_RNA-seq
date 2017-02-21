#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=24G


SCRIPT_DIR=$1
shift
#FORWARD=$1
#shift
#OUT=$1
#shift

abyss-pe $@

