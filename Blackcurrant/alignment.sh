# create salmon index
salmon index -t $PROJECT_FOLDER/data/genome/transcriptome.fasta -i $PROJECT_FOLDER/data/genome/SALMON_quasi

# create a mapping file of transcripts to genes for testing Salmon -g flag
...
\ >trans_2_gene.txt

# psuesdo-alignment (note names of unmapped reads have been retained for later use...)
for FR in $PROJECT_FOLDER/data/filtered/*_1.filtered.fq.gz; do
 RR=$(sed 's/_1/_2/' <<< $FR)
 OUTDIR=$(awk -F"/" '{print $NF}' <<< $FR|sed 's/_.*//')
 $PROJECT_FOLDER/RNA-seq_pipeline/scripts/PIPELINE.sh -c salmon \
 $PROJECT_FOLDER/data/genome/SALMON_quasi \
 $PROJECT_FOLDER/data/counts/$OUTDIR \
 $FR $RR \
 --numBootstraps 1000 --dumpEq --seqBias --gcBias --writeUnmappedNames -g trans_2_gene.txt
done

# -g checking trans_2_gene.txt should match trans2gene.txt
awk -F"\t" '{c=$1;sub("\..*","",$1);print c,$1}' OFS="\t" quant.sf >trans2gene.txt
