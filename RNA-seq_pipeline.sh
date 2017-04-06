#trim
for R1 in $STRAW/../raw/D*_1.fq; do
  R2=$(echo $R1|sed 's/_1/_2/');
  $STRAW/RNA-seq_pipeline/scripts/PIPELINE.sh -c trim \
  $R1 \
  $R2 \
  $STRAW/trimmed \
  $STRAW/RNA-seq_pipeline/scripts/truseq.fa \
  4
done
