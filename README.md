# AMF-strawberry_RNA-seq

There's no transciptome for the octoploid - will need to build one.

Two transcriptomes will be built - de novo and genome guided de novo. 

Genome guided will have an extra step of aligning reads to the reference genome.

## STUFF TO DO
I'm going to split this into two projects 
### Denovo_transcriptome-pipeline
Denove transcriptome of polyploid plants
### RNA-seq_projects
An RNA-seq_pipeline project already exists in eastmallingresearch, I'll create (or rename this) a new project folder as per metbarcoding_projects  

The stuff below is for the denovo pipeline  
There are a few R scripts with DGE analysis which will go in the projects folder



## QC
FastQC
## Denovo assembly

### Split files
The files are large - some of the steps will get better performance on the cluster by splitting data into chunks (and 32bit version of usearch won't run out of memory).

 Num_reads of about 5,000,000 works well
```shell
PIPELINE.sh -c splitfq fastq_file num_reads outdir 
```
### Trim adapters 
With trimmomatic
```shell
PIPELINE.sh -c trim left right outdir adapters.fa threads [options]
```
Further trimmomatic options can be appended if required

### Quality filter and joining
Quality score is based on the expected number of errors in a sequence. Seqeunce is dropped if the error rate is above that specified.

Join and filter
```shell
PIPELINE.sh -c join left right outdir max_diff min_length quality #max_diff % mismatches in join
```

Filter only

qual_left=0.1 qual_right=0.25 removes about 30% of my data (this is a good thing)
```shell
PIPELINE.sh -c clean left right outdir qual_left qual_right
```
### Phix rRNA/chloroplast/mitochondion filter
Make Phix etc. Bowtie2 index
```
bowtie2-build contaminants.fa contaminants
```
Remove contaminants
```
PIPELINE.sh -c filter -v <paired|unpaired> contaminants outdir <joined_fq|left right>
```

### Dereplicate/normalise or something else
dereplicate.sh (this may mess up some of the trinity processing as it uses sequence depth to guess isoforms)

normalise.sh (using trinity)
Accepts lists of files - this doesn't work correctly, only processes first entry

```
find . -name '*.f.*'|sort|xargs -I% cat % > f.fa
find . -name '*.r.*'|sort|xargs -I% cat % > r.fa

PIPELINE.sh -c normalise $OUTDIR --seqType fa --JM 320G --max_cov 35 --left f.fa --right r.fa --pairs_together --CPU 16 
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
Genome-guided with trinity
```
PIPELINE.sh -c assemble \
 trinity \
 --genome_guided_bam $STRAWBERRY/aligned/D20.2Aligned.sortedByCoord.out.bam \
 --genome_guided_max_intron 10000 \
 --max_memory 320G \
 --CPU 16 \
 --grid_node_CPU 2 \
 --grid_node_max_memory 2G \
 --output $STRAWBERRY/assembled/trinity_D20
```

Trinity De-novo
```
PIPELINE.sh -c assemble \
 trinity \
 --no_normalize_reads \
 --full_cleanup \
 --max_memory 320G \
 --CPU 16 \
 --grid_node_CPU 2 \
 --grid_node_max_memory 2G \
 --output $STRAWBERRY/assembled/trinity_D20_C35
```

Velvet/Oases de-novo
```


```

### Transcript quality filter
The assemblies are going to produce a lot of contigs/transcripts. The idea of this section is to find the set of "best" transcripts.

Something like tr2aacds pipeline?


derep_fragments (should) removes all exact fragments, but takes hours to run. cluster_fast by contrast uses a heuristic method for determining if a sequence matches, or not - and takes only minutes to run on a 100meg file.

```
dereplicate.pl # also renames contigs
get_longest_cds.pl
# dereplicate.pl - usearch will do this
# sort_fasta.pl - usearch will do this
# derep_fragments.pl # this is mega slow
usearch9 -cluster_fast in.fa -id 1 -strand plus -sort length -centroids out.fa # this is miles faster, but memory will limit the number of transcripts that can be processed - good reason to buy 64bit version?

#dereplicate_v2.pl trinity_D20_C35.Trinity.fasta> trinity_D20_C35_dereplicated.fasta


usearch9 -cluster_fast trinity_D20_C35_dereplicated.fasta -sort length -strand both -id 0.99 -sizeout -centroids trinity_D20_C35_0.99-centroids.fasta
#cap3 trinity_D20_C35_0.99-centroids.fasta >cap3_D20_C35_0.99.output
```


### Align to reference genome

Find sequence lengths
```
awk '/^>/ {if (seqlen){print (x,seqlen)}; x=$1 ;seqlen=0;next; } { seqlen += length($0)}END{print (x,seqlen)}' fasta.fa
```

Align with star (some of these setting probably need tweaking)
```
STARlong 
 --genomeDir $STRAWBERRY/genome/star_octo/ \
 --outFileNamePrefix D1 \
 --readFilesIn $STRAWBERRY/assembled/D1_sort_uniq.fa \
 --runThreadN 16 \
 --outFilterMultimapScoreRange 20   \
 --outFilterScoreMinOverLread 0   \
 --outFilterMatchNminOverLread 0.66   \
 --outFilterMismatchNmax 1000   \
 --winAnchorMultimapNmax 200   \
 --seedSearchLmax 30   \
 --seedSearchStartLmax 12   \
 --seedPerReadNmax 100000   \
 --seedPerWindowNmax 100   \
 --alignTranscriptsPerReadNmax 100000   \
 --alignTranscriptsPerWindowNmax 10000
```
