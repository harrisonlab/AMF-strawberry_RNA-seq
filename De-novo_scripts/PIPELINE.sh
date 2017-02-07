#!/bin/bash

SCRIPT_DIR=$(readlink -f ${0%/*})

#==========================================================
#	Set Help (add message between EOM blocks
#==========================================================	
read -r -d '' HELP << EOM
#############################################################
#							#
#	Denovo transcriptome pipeline	for Illumina RNA-seq			#
#							#
#	usage: PIPELINE.sh -c <program> [options]	#
#							#
#############################################################

 -c <program>	Program can be any of the defined programs
 -h		display this help and exit	
EOM


function print_help {
	echo;echo "$HELP" >&1;echo;
	exit 1
}

if [ $# -eq 0 ];
then
   print_help
fi

#==========================================================
#	Set command line switch options
#==========================================================

OPTIND=1 

while getopts ":hc:" options; do
	case "$options" in
	c)  
 	    program=$OPTARG
	    break
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
      	    ;;
	h)  
	    print_help
	    exit 0
 	    ;;
	?) 
	    echo "Invalid option: -$OPTARG" >&2
	    echo "Call PIPELINE with -h switch to display usage instructions"
	    exit 1
	    ;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

#==========================================================
#	Set (-c) programs
#==========================================================

case $program in

wibble)
	exit 1
;;
split|splitfq|splitfq.sh)
	$SCRIPT_DIR/splitfq.sh $@
	exit 0
;;
trim|trim.sh)
	$SCRIPT_DIR/trim.sh $@
	exit 0
;;
clean|clean.sh)
	$SCRIPT_DIR/clean.sh $@
	exit 0
;;
#join|joins.sh)
#	$SCRIPT_DIR/join.sh $@
#	exit 0
#;;
filter|filter.sh)
	$SCRIPT_DIR/filter.sh $@
	exit 0
;;
normalise|normalise.sh)
	$SCRIPT_DIR/normalise.sh $@
	exit 0
;;
align|align.sh|star)
	$SCRIPT_DIR/star.sh $@
	exit 0
;;
dereplicate|dereplicate.sh)
	$SCRIPT_DIR/dereplicate.sh $@
	exit 0
;;

assemble|assemble.sh)
	$SCRIPT_DIR/assemble.sh $@
	exit 0
;;

preprocess)

	INDIR=$1
	shift
	OUTDIR=$1
	shift
	JOBNAME=DENOVO_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head)
	
	TEMPDIR=`mktemp -d -p $OUTDIR`
	find $UNFILTDIR -name '*.fastq' >$TEMPDIR/files.txt
	TASKS=$(wc -l $TEMPDIR/files.txt|awk -F" " '{print $1}')

	qsub -N ${JOBNAME}_1 -t 1-$TASKS:1 $SCRIPT_DIR/submit_fastq_fasta.sh $dir/files.txt $dir $SL $SR $SCRIPT_DIR



	qsub -N ${JOBNAME}_1 $SCRIPT_DIR/trim.sh $@
	qsub -hold_jid ${JOBNAME}_1 -N ${JOBNAME}_2 $SCRIPT_DIR/join.sh $@
	qsub -hold_jid ${JOBNAME}_2 -N ${JOBNAME}_3 $SCRIPT_DIR/dereplicate.sh $@
	qsub -hold_jid ${JOBNAME}_3 -N ${JOBNAME}_4 $SCRIPT_DIR/filter.sh $@
	qsub -hold_jid ${JOBNAME}_4 $SCRIPT_DIR/tidy.sh $@ 
	exit 0
;;
assembly|assembly.sh)
	echo $SCRIPT_DIR/assembly.sh $@
	exit 0
;;
TEST)
	echo "test program run with options:" $@
	exit 0
;;

*)
	echo "Invalid program: $program" >&2
	exit 1
esac
