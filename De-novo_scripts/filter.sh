#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l virtual_free=2G

read -r -d '' HELP << EOM
#################################################################################
#										#
#	Wrapper script for contaminant filtering					#
#										#
#	usage: filter.sh -p <program> [options]					#
#										#
#	-p <bowtie|ublast>							#
#										#
#	filter.sh Ref_genome Out_dir read1,read2,etc <-f|-q> [options]	 		#
#	 									#
#	Some useful options							#
#	-p <num_processors>				   			#							
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

while getopts ":hs:" options; do
	case "$options" in
	s)
	  SCRIPT_DIR=$OPTARG
	  ;;
	h)  
	  print_help
	  exit 0
	  ;;
	esac

done


[ "$1" = "--" ] && shift

if [[ -z "$SCRIPT_DIR" ]]; then 
	SCRIPT_DIR=$(readlink -f ${0%/*})
fi

# note bowtie will use the same file name for all output files -
qsub -l h=!blacklace11 $SCRIPT_DIR/submit_bowtie.sh $@

