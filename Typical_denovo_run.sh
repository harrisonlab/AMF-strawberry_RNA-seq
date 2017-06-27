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

# Transrate

# Cat and filter
# cd_hit 95%, ublast 97% (filter.R)

> transcript.fa

# create mrna/transcrits for diploid from gff + genome
grep -P "mRNA[^;]" GCF_000184155.1_FraVesHawaii_1.0_genomic.gff|awk -F"\t" '{gsub(/.*transcript_id=/,"",$NF);print $NF,$1,$4,$5,$7}' OFS="\t"  > mrna.vesca.saf
```R
library(Biostrings)
vesca <- readDNAStringSet("GCF_000184155.1_FraVesHawaii_1.0_genomic.fna")
mrna <- read.table(mrna.vesca.saf,header=F)
mytranscripts<-DNAStringSet(x=vesca[mrna[,2]],start=mrna[,3],end=mrna[,4])
mytranscripts@ranges@NAMES <- mrna[,1]
writeXStringSet(mytranscripts,"vesca.transcripts.fa",format="fasta")
```


# Align with STAR to diploid genome to look for chimeras

STAR 	--genomeDir $STAR_DN/../genome/star_diploid \ # edit this 
	--input $STRAW_DN/transcriptome/transcripts.fa \ # edit this 
	--outFilterMultimapScoreRange 20 \
	--outFilterScoreMinOverLread 0   \
	--outFilterMatchNminOverLread 0.66 \
	--outFilterMismatchNmax 1000   \
	--winAnchorMultimapNmax 200   \
	--seedSearchLmax 30   \
	--seedSearchStartLmax 12  \
	--seedPerReadNmax 100000   \
	--seedPerWindowNmax 100   \
	--alignTranscriptsPerReadNmax 100000   \
	--alignTranscriptsPerWindowNmax 10000 \
	---outReadsUnmapped Fastx \
	--outFileNamePrefix diploid_trans \
	--chimOutType SeparateSAMold \
	--chimSegmentMin 50
	
# create gff
grep "^@" -v Aligned.out.sam|awk -F"\t" '{print $1,$2,$3,$4,$5,length($10),$12}' OFS="\t"| \
awk -F"\t" '{x=x+1;if($2==16||$2==272){start=$4-$6+1;d=start"\t"$4"\t0\t-"}else{end=$4+$6-1;d=$4"\t"end"\t0\t+"}; \
	     print "TA"x,"GD_STAR","transcript",d,"0","transcript_origin \""$1"\""}' OFS="\t" > transcripts.gff


grep "^@" -v Aligned.out.sam|awk -F"\t" '{print $1,$2,$3,$4,$5,length($10),$12}' OFS="\t"| \
awk -F"\t" '{x=x+1;end=$4+$6-1;d=$4"\t"end"\t0\t+"; \
	     print "TA"x,"GD_STAR","transcript",d,"0","transcript_origin \""$1"\""}' OFS="\t" > transcripts.gff

grep ">" Unmapped.out.mate1|
sed -e 's|>||'|
awk -F"_" '{x=x+1;print "TU"x,"GD_PIPE","transcript","1",$5,"0","+","0","transcript_origin \""$0"\""}' OFS="\t" >> transcripts.gff

