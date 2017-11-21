PROJECT_FOLDER=~/projects/strawberry/data/RNA_seq_analysis

# trim
for FR in $PROJECT_FOLDER/../raw/D*_1.fq; do
  RR=$(echo $FR|sed 's/_1/_2/');
  $PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c trim \
  $FR \
  $RR \
  $PROJECT_FOLDER/trimmed \
  $PROJECT_FOLDER/RNA-seq_pipeline/scripts/truseq.fa \
  4
done

# filter
for FR in $PROJECT_FOLDER/trimmed/D*_1*; do
  RR=$(echo $FR|sed 's/_1/_2/');
  S=$(echo $FR|awk -F"/" '{print $NF}'|awk -F"_" '{print $1,$2,$3}' OFS="_")
  $PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c filter \
  $PROJECT_FOLDER/../contaminants/contaminants \
  $FR $RR \
  $PROJECT_FOLDER/filtered
done

# pseudo align and count with salmon
for FR in $PROJECT_FOLDER/filtered/D*_1*; do
  RR=$(echo $FR|sed -e 's/_1/_2/')
  OUTDIR=$(echo $FR|awk -F"/" '{print $NF}'|sed 's/_.*//')
  $PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c salmon \
  $PROJECT_FOLDER/../genome/SALMON_diploid \
  $PROJECT_FOLDER/counts/salmon/$OUTDIR \
  $FR $RR \
  --numBootstraps 1000 --dumpEq --seqBias --gcBias
done
