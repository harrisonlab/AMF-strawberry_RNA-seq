# AMF-strawberry_RNA-seq

There's no transciptome for the octoploid - will need to build one.

Two transcriptomes will be built - de novo and genome guided de novo. 

Genome guided will have an extra step of aligning reads to the reference genome.

## QC
FastQC
## Denovo assembly

### Split files
The files are large - some of the steps will get better performance on the cluster by splitting data into chunks.
```shell
splitfq.sh 
```
### Trim adapters
trimmomatic
### Quality filter and joining
usearch
### Phix rRNA/cloroplast/mitochondion filter
bowtie2 
### Dereplicate/normalise or something else
dereplicate.sh (this may mess up some of the trinity processing as it uses sequence depth to guess isoforms)
normalise.sh (using trinity)
```
PIPELINE.sh -c normalise fa --JM 320G --max_cov 25 --left F --right R --pairs_together --output $OUTDIR --CPU 16 
```

### Align to genome
For genome guided assembly only 
```
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
```

### Assemble
Genome-guided
```
PIPELINE.sh -c assemble \
 --genome_guided_bam $STRAWBERRY/aligned/D20.2Aligned.sortedByCoord.out.bam \
 --genome_guided_max_intron 10000 \
 --max_memory 320G \
 --CPU 16 \
 --grid_node_CPU 2 \
 --grid_node_max_memory 2G \
 --output $STRAWBERRY/assembled/trinity_D20
```

### Dereplicate transcripts
```
get_unip.pl transcripts.fa > unique_transcripts.fa
```
### Quality check transcripts


### Merge transcriptomes 


### Align to reference genome

Find sequence lengths
```
awk '/^>/ {if (seqlen){print (x,seqlen)}; x=$1 ;seqlen=0;next; } { seqlen += length($0)}END{print (x,seqlen)}' fasta.fa
```

Align with star (some of these setting probably need tweaking)
```
STARlong 
 --genomeDir $STRAWBERRY/genome/star_octo/ 
 --outFileNamePrefix D1 
 --readFilesIn $STRAWBERRY/assembled/D1_sort_uniq.fa 
 --runThreadN 16 
 --outFilterMultimapScoreRange 20   
 --outFilterScoreMinOverLread 0   
 --outFilterMatchNminOverLread 0.66   
 --outFilterMismatchNmax 1000   
 --winAnchorMultimapNmax 200   
 --seedSearchLmax 30   
 --seedSearchStartLmax 12   
 --seedPerReadNmax 100000   
 --seedPerWindowNmax 100   
 --alignTranscriptsPerReadNmax 100000   
 --alignTranscriptsPerWindowNmax 10000
```
