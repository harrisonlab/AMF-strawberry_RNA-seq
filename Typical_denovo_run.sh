#split
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c splitfq \
  $STRAW_DN/../raw/D2_1.fq.gz \
  5000000 \
  $STRAW_DN/split

$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c splitfq \
  $STRAW_DN/../raw/D2_2.fq.gz \
  5000000 \
  $STRAW_DN/split

#trim
for R1 in $STRAW_DN/split/D2_1.fq.gz.aaaa*; do
  R2=$(echo $R1|sed 's/_1/_2/');
  $STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c trim \
  $R1 \
  $R2 \
  $STRAW_DN/trimmed \
  $STRAW_DN/Denovo-assembly_pipeline/scripts/truseq.fa \
  4
done

#clean
for R1 in $STRAW_DN/trimmed/D2_1.fq.gz.aaaa*; do
  R2=$(echo $R1|sed 's/_1/_2/');
  $STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c clean \
  $R1 \
  $R2 \
  $STRAW_DN/cleaned \
  0.1 \
  0.25
done

#filter
for R1 in $STRAW_DN/cleaned/D2_1.fq.gz.aaaa*.f.*; do 
  R2=$(echo $R1|sed 's/\.f\./\.r\./'); 
  $STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c filter \
  $STRAW_DN/../contaminants/contaminants \
  $STRAW_DN/filtered \
  $R1 $R2
done

#concatenate
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c concat \
  $STRAW_DN/filtered \
  D2
  
#normalise
#find $STRAW_DN/filtered -name '*.f.*'|sort|xargs -I% cat % > $STRAW_DN/filtered/D2_F
#find $STRAW_DN/filtered -name '*.r.*'|sort|xargs -I% cat % > $STRAW_DN/filtered/D2_R

$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c normalise \
  $STRAW_DN/filtered \
  $STRAW_DN/normalised/D2 \
  --seqType fa \
  --JM 320G \
  --max_cov 35 \
  --left D2_F \
  --right D2_R \
  --pairs_together \
  --CPU 16 

#correct read order (the normalise process doesn't guarantee pairs in same order - plus a few unmatched pairs get through)
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c correct \
 $STRAW_DN/normalised/D2/D2_F.normalized_K25_C35_pctSD200.fa \
 $STRAW_DN/normalised/D2/D2_R.normalized_K25_C35_pctSD200.fa \
 $STRAW_DN/normalised/D2
 
 #interleave fasta files (for velvet/oases)
 $STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c interleave \
 $STRAW_DN/normalised/D2/D2_C35_F_1.fa \
 $STRAW_DN/normalised/D2/D2_C35_R_2.fa \
 $STRAW_DN/normalised/D2

#------ ALL THE ABOVE
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c MEGA \
  $STRAW_DN \
  D2 \
  5000000
#-----


#Assemble Trintity
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble \
 trinity \
 --seqType fa \
 --left $STRAW_DN/normalised/D2/D2_F_K35_1.fa \
 --right $STRAW_DN/normalised/D2/D2_R_K35_2.fa \
 --output $STRAW_DN/assembled/trinity_D2 \
 --full_cleanup \
 --max_memory 320G \
 --CPU 16 \
 --grid_node_CPU 2 \
 --grid_node_max_memory 2G

 #--no_normalize_reads for latest version of trinity
 
#Assemble Velvet/Oases
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble velveth \
 $STRAW_DN/assembled/D2/velveth_C35 \
 $STRAW_DN/normalised/D2/D2_C35.fa

for k in {21..65..4}; do
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble vo \
	$k \
	$STRAW_DN/assembled/D2/velveth_C35 \
	$STRAW_DN/assembled/D2/oases_C35
done

for k in {71..119..8}; do
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble vo \
	$k \
	$STRAW_DN/assembled/D2/velveth_C35 \
	$STRAW_DN/assembled/D2/oases_C35
done
  
#Assemble TransAbyss  
#Assemble SOAP



# Filter transcripts
 $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl trinity_D1.Trinity.fasta > out1.fa
 $STRAW_DN/Denovo-assembly/scripts/get_longest_cds.pl out1.fa >cds.fa
 cd-hit-est -c 1.0 -i cds.fa -o cds.defrag.fa
 $STRAW_DN/Denovo-assembly/scripts/sort_fasta.pl cds.defrag.fa >cds.defrag.sorted.fa
# usearch9 -cluster_fast in.fa -id 1 -strand plus -sort length -centroids out.fa
# $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl| \

 
