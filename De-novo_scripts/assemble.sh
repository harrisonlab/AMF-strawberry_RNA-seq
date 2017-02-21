#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

read -r -d '' HELP << EOM
#################################################################################
#										#
#	Wrapper script for quality filtering RNA-seq data		#
#										#
#	usage: assemble.sh -p <program> [options]					#
#										#
#	-p ignored, usearch is only option					#
#										#
#	clean.sh forward reverse out_dir forward_quality reverese_quality [options]	#
#	 									#
#	 									#
#################################################################################
EOM

function print_help {
	echo;echo "$HELP" >&1;echo;
	exit 0
}

if [ $# -eq 2 ];
then
   print_help
fi

OPTIND=1

while getopts ":hsp:" options; do
	case "$options" in
	s)
	  SCRIPT_DIR=$OPTARG
	  ;;
	p)
	  program=$OPTARG
	  break
	  ;;
	h)  
	  print_help
	  exit 0
	  ;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [[ -z "$SCRIPT_DIR" ]]; then 
	SCRIPT_DIR=$(readlink -f ${0%/*})
fi


#qsub -l h=blacklace11 $SCRIPT_DIR/submit_assemble.sh $SCRIPT_DIR $FORWARD $OUT

case $program in

trinity|Trinity|Tr)
	qsub -l h=blacklace11 $SCRIPT_DIR/submit_trinity.sh $SCRIPT_DIR $@
	exit 0
;;
Trans|Ta|abyss|TransAbyss)
	qsub -l h=blacklace11 $SCRIPT_DIR/submit_transabyss.sh $SCRIPT_DIR $@
	exit 0
;;
Oases|Velvet|Oa)
	qsub -l h=blacklace11 $SCRIPT_DIR/submit_oases.sh $SCRIPT_DIR $@
	exit 0
;;
*)
	echo "Invalid assembly program: $program" >&2
	exit 1
esac
	