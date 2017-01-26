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
### Join reads and quality filter
usearch
### Phix rRNA/cloroplast/mitochondion filter
bowtie2 or ublast
### Dereplicate/normalise or something else
dereplicate.sh (this may mess up some of the trinity processing as it uses sequence depth to guess isoforms)
normalise.sh (using trinity) 
### Assemble
trinity
### Align
Dereplicate (useful here) assembled output and align to genome.

