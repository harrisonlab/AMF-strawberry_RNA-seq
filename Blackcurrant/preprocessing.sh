# create folders
PROJECT_FOLDER=~/projects/blackcurrant

ln -s  ~/pipelines/RNA-seq $PROJECT_FOLDER/RNA-seq_pipeline

mkdir $PROJECT_FOLDER/cluster
mkdir -p $PROJECT_FOLDER/data/fastq
mkdir $PROJECT_FOLDER/data/trimmed
mkdir $PROJECT_FOLDER/data/filtered
mkdir $PROJECT_FOLDER/data/aligned
mkdir $PROJECT_FOLDER/data/counts

mkdir -p $PROJECT_FOLDER/analysis/quality
mkdir $PROJECT_FOLDER/analysis/DGE
mkdir $PROJECT_FOLDER/analysis/DEU

ln -s /somesir/data/rna-seq/blackcurrent_project_xxx/data $PROJECT_FOLDER/data/fastq/.

# quality chech
for FILE in $PROJECT_FOLDER/data/fastq/*.gz; do 
	$PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c qcheck $FILE $PROJECT_FOLDER/analysis/quality
done

# remove adapter contaminatation (not quality trimming)
for FR in $PROJECT_FOLDER/data/fastq/*_1.fq.gz; do
 RR=$(sed 's/_1/_2/' <<< $FR)
 $PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c trim \
 $FR \
 $RR \
 $PROJECT_FOLDER/data/trimmed \
 $PROJECT_FOLDER/RNA-seq_pipeline/scripts/truseq.fa \
 4
done

# filter phix etc. (this is memory intensive)
for FR in $PROJECT_FOLDER/data/trimmed/*_1.fq.gz.trimmed.fq; do
  RR=$(sed 's/\_1\.fq/\_2\.fq/' <<<$FR)
  $PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c filter \
  $PROJECT_FOLDER/RNA-seq_pipeline/phix/phix \
  $PROJECT_FOLDER/filtered \
  $FR $RR
done
