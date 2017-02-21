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

#normalise
find $STRAW_DN/filtered -name '*.f.*'|sort|xargs -I% cat % > $STRAW_DN/filtered/D2_F
find $STRAW_DN/filtered -name '*.r.*'|sort|xargs -I% cat % > $STRAW_DN/filtered/D2_R

$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c normalise \
  $STRAW_DN/normalised/D2 \
  --seqType fa \
  --JM 320G \
  --max_cov 35 \
  --left $STRAW_DN/filtered/D2_F \
  --right $STRAW_DN/filtered/D2_R \
  --pairs_together \
  --CPU 16 

#correct read order (the normalise process doesn't guarantee pairs in same order - plus a few unmatched pairs get through)
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c correct \
 $STRAW_DN/normalised/D2/D2_F.normalized_K25_C35_pctSD200.fa \
 $STRAW_DN/normalised/D2/D2_R.normalized_K25_C35_pctSD200.fa \
 $STRAW_DN/normalised/D2

#Assemble Trintity
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble \
 trinity \
 --seqType fa \
 --left $STRAW_DN/normalised/D2/D2_F_K35_1.fa \
 --right $STRAW_DN/normalised/D2/D2_R_K35_2.fa \
 --output $STRAW_DN/assembled/trinity_D2 \
 --no_normalize_reads \
 --full_cleanup \
 --max_memory 320G \
 --CPU 16 \
 --grid_node_CPU 2 \
 --grid_node_max_memory 2G

#Assemble TransAbyss
#Assemble Velvet/Oases
$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c interleave \
 $STRAW_DN/normalised/D2/D2_C35_F_1.fa \
 $STRAW_DN/normalised/D2/D2_C35_R_2.fa \
 $STRAW_DN/normalised/D2

velveth test 21 -fasta -shortPaired D2_C35.fa -noHash -create_binary
mkdir K71
ln test/* K71/.
velveth K71 71 -reuse_Sequences -create_binary
velvetg K71 -read_trkg yes
oases K71 -ins_length 250 
  
#Assemble SOAP



# Filter transcripts
 $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl trinity_D1.Trinity.fasta| \
 $STRAW_DN/Denovo-assembly/scripts/get_longest_cds.pl| \
 $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl| \
 $STRAW_DN/Denovo-assembly/scripts/sort_fasta.pl >cds.derep.sorted.fa
