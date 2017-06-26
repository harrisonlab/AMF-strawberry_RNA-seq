# trim
for R1 in $STRAW/../raw/D*_1.fq; do
  R2=$(echo $R1|sed 's/_1/_2/');
  $STRAW/RNA-seq_pipeline/scripts/PIPELINE.sh -c trim \
  $R1 \
  $R2 \
  $STRAW/trimmed \
  $STRAW/RNA-seq_pipeline/scripts/truseq.fa \
  4
done

# filter
for R1 in $STRAW/trimmed/D*_1*; do
  R2=$(echo $R1|sed 's/_1/_2/');
  S=$(echo $R1|awk -F"/" '{print $NF}'|awk -F"_" '{print $1,$2,$3}' OFS="_")
  $STRAW/RNA-seq_pipeline/scripts/PIPELINE.sh -c filter \
  $STRAW/../contaminants/contaminants \
  $R1 $R2 \
  $STRAW/filtered
done

# align
for R1 in $STRAW/filtered/D*_1*; do  
 R2=$(echo $R1|sed -e 's/_1/_2/');  
 pre=$(echo $R1|awk -F"/" '{gsub(/_.*/,"",$NF);print $NF}');  
 $STRAW/RNA-seq_pipeline/scripts/PIPELINE.sh -c star \
 $STRAW/../star_diploid \
 $STRAW/aligned/diploid $pre $R1 $R2 \
 --readFilesCommand zcat -outSAMtype BAM Unsorted; 
done

# counts
for f in $STRAW/aligned/diploid/D*.Aligned.out.sam.bam; do
  OUTFILE=$(echo $f|awk -F"/" '{gsub(/\..*/,"",$NF);print $NF}').counts
  $STRAW/RNA-seq_pipeline/scripts/PIPELINE.sh -c counts \
  $STRAW/counts/diploid.SAF \
  $STRAW/counts \
  $OUTFILE \
  $f -T 12 -M -F SAF
done
