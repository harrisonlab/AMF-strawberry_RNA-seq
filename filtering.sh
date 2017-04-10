# $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl trinity_D1.Trinity.fasta > out1.fa
# $STRAW_DN/Denovo-assembly/scripts/get_longest_cds.pl out1.fa >cds.fa
# cd-hit-est -c 1.0 -i cds.fa -M 0 -T 8 -o cds.defrag.fa
 #$STRAW_DN/Denovo-assembly/scripts/sort_fasta.pl cds.defrag.fa >cds.defrag.sorted.fa
# $STRAW_DN/Denovo-assembly/scripts/dereplicate.pl| \

# Combine filtered transcripts and filter round 2 
# First step is to check for complete cds at least 75 
cat *C35*.fa | grep -P -A1 --no-group-separator "_\d*_3C$" | \
~/pipelines/Denovo-assembly/scripts/get_complete_cds.pl | \
~/pipelines/Denovo-assembly/scripts/sort_fasta.fa > filtered.cds.fa 
cd-hit-est -c 0.97 -i filtered.cds.fa -M 0 -T 8 -o  combined.clustered.fa 
usearch9 -makeudb_ublast combined.clustered.fa -output db.udb 
usearch9 -ublast combined.clustered.fa -db db.udb -id 0.97 -evalue 1e-2 -accel 0.06 -strand plus -userout res.uo  -userfields query+target+clusternr+id+ql+tl+qcov+tcov+diffs+caln
Rscript filter.R res.uo
usearch9 -fastx_getseqs combined.clustered.fa -labels transcripts.txt -fastaout transcripts.fa 

for D in $STRAW_DN/assembled/D*; do 
	$STRAW_DN/Denovo-assembly_pipeline/scripts/PIPELINE.sh -c post2 \
	$D/filtered.cds.fa 
	$D/final_cds; 
done


#awk -F"_" '{if(NF>1){x=$5-$7*3;if(x>=75){k=1}else{k=0};}if(k==1){print}}' > filtered.cds.fa
#awk -F"\t" '{a=substr($1,length($1),1);b=substr($1,length($1)-4,1);if(a=="C"&&b!="-"){x="C"}else{x="I"};$(NF+1)=x;a=substr($2,length($2),1);b=substr($2,length($2)-4,1);if(a=="C"&&b!="-"){x="C"}else{x="I"};$(NF+1)=x;print}' OFS="\t" res2.uo >res.f.uo

#~/pipelines/Denovo-assembly/scripts/sort_fasta.pl transcripts.fa|
#awk -F"_" '{if(NF>1){x=$7;k=1;}else{k=0};if(k==1){print}else{y=substr($1,x*3+1);k==1;print y}}' > cds.transcripts.fa

# Filter no. 3
for D  in D*; do 
	cat $D/final_cds/transcripts.fa >>transcripts.fa; 
done
cd-hit-est -c 0.97 -i transcripts.fa -M 0 -T 8 -o  derep.fa
usearch9 -makeudb_ublast derep.fa -output db.udb #could be close to 32 bit usearch mem limit
usearch9 -ublast derep.fa -db db.udb -id 0.97 -evalue 1e-2 -accel 0.06 -strand plus -userout res.uo  -userfields query+target+clusternr+id+ql+tl+qcov+tcov+diffs+caln

