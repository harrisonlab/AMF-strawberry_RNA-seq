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

Align to genome

For genome guided assembly only

### Generate index
STAR --runMode genomeGenerate --genomeDir $OUTDIR --genomeFastaFiles redgauntlet.fa --sjdbGTFfile redgauntlet.gff --genomeChrBinNbits 11
### Align reads
STAR \
 --genomeDir $STRAWBERRY/genome/star_octo/ \
 --outFileNamePrefix $STRAWBERRY/aligned/D20.2 \
 --readFilesIn  $STRAWBERRY/normalised/left.norm.fa $STRAWBERRY/normalised/right.norm.fa \
 --runThreadN 16 \
 --outSAMtype BAM SortedByCoordinate \
 --outFilterMatchNminOverLread 0.4 \
 --outFilterScoreMinOverLread 0.4
Assemble

Genome-guided with trinity

PIPELINE.sh -c assemble \
 trinity \
 --genome_guided_bam $STRAWBERRY/aligned/D20.2Aligned.sortedByCoord.out.bam \
 --genome_guided_max_intron 10000 \
 --max_memory 320G \
 --CPU 16 \
 --grid_node_CPU 2 \
 --grid_node_max_memory 2G \
 --output $STRAWBERRY/assembled/trinity_D20

#Assemble Trintity (De novo)
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
 
 #Assemble Trintity genome guided
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
transabyss --pe D2_C35.fa --mpi 8 --threads 8 --kmer 34

mkdir -p $STRAW_DN/assembled/D2/trans_C35
for k in {22..66..4}; do
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c trans TRANS \
	$STRAW_DN/assembled/D2/trans_C35
	$k
	--k $k \
	--pe $STRAW_DN/normalised/D2/D2_C35.fa
done

for k in {72..120..8}; do
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble TRANS \
	$STRAW_DN/assembled/D2/trans_C35
	$k
	--k $k \
	--pe $STRAW_DN/normalised/D2/D2_C35.fa
done	

#Assemble SOAP

mkdir -p $STRAW_DN/assembled/D2/soap_C35
cp $STRAW_DN/Denovo-assembly_pipeline/scripts/soap_config $STRAW_DN/assembled/D2/soap_C35/soap_config
sed -i -e "s|MYINTERFILE|$STRAW_DN/normalised/D2/D2_C35.fa|" $STRAW_DN/assembled/D2/soap_C35/soap_config

for k in {21..65..4}; do
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble SOAP \
	all \
	-K $k \
	-s $STRAW_DN/assembled/D2/soap_C35/soap_config
done

for k in {71..119..8}; do
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c assemble SOAP \
	all \
	-K $k \
	-s $STRAW_DN/assembled/D2/soap_C35/soap_config
done

# Filter transcripts
cat  $STRAW_DN/assembled/D2/oases_C35/*.fa > combined.fa

$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c post \
  $STRAW_DN/assembled/D2/oases_C35/combined.fa \
  D2_oases_C35 \
  $STRAW_DN/assembled/D2 

 $STRAW_DN/assembled/D2/*C35*; do 
 	p=$(echo $D|awk -F"/" '{print $(NF-1),$NF}' OFS="_"); 
  	 $STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c post \
	  $D/combined.fa \
	  $p \
	  $STRAW_DN/assembled/D2; 
done


 $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl trinity_D1.Trinity.fasta > out1.fa
 $STRAW_DN/Denovo-assembly/scripts/get_longest_cds.pl out1.fa >cds.fa
 cd-hit-est -c 1.0 -i cds.fa -M 0 -T 8 -o cds.defrag.fa
 #$STRAW_DN/Denovo-assembly/scripts/sort_fasta.pl cds.defrag.fa >cds.defrag.sorted.fa
# usearch9 -cluster_fast in.fa -id 1 -strand plus -sort length -centroids out.fa
# $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl| \

# Combine filtered transcripts and filter round 2
cat soap/ trinity/ oases/ trans/ combined.fa > combined.fa
$STRAW_DN/Denovo-assembly/scripts/sort_fasta > combined_sorted.fa #filters out less than 75 length
cd-hit-est -c 1.0 -i combined_sorted.fa -M 0 -T 8 -o combined.defrag.fa 

usearch9 -makeudb_ublast combined.defrag.fa  -output db.udb # likely to very close to 32 bit usearch mem limit
usearch9 -ublast combined.defrag.fa -db db.udb -id 0.97 -evalue 1e-2 -accel 0.06 -strand plus -userout res2.uo  -userfields query+target+clusternr+id+ql+tl
awk -F"\t" '{a=substr($1,length($1),1);b=substr($1,length($1)-4,1);if(a=="C"&&b!="-"){x="C"}else{x="I"};$(NF+1)=x;a=substr($2,length($2),1);b=substr($2,length($2)-4,1);if(a=="C"&&b!="-"){x="C"}else{x="I"};$(NF+1)=x;print}' OFS="\t" res2.uo >res.f.uo

# then process in R 
