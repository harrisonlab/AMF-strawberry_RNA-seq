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
