```
for R1 in /home/deakig/projects/strawberry/data/De_novo_assembly/split/D2_1.fq.gz.aaaa*; do
R2=$(echo $R1|sed 's/_1/_2/');
/home/deakig/pipelines/Denovo-assembly/scripts/PIPELINE.sh -c trim 


for R1 in /home/deakig/projects/strawberry/data/De_novo_assembly/cleaned/D2_1.fq.gz.aaaa*.f.*; do 
R2=$(echo $R1|sed 's/\.f\./\.r\./'); 
/home/deakig/pipelines/Denovo-assembly/scripts/PIPELINE.sh -c filter /home/deakig/projects/strawberry/data/contaminants/contaminants /home/deakig/projects/strawberry/data/De_novo_assembly/filtered $R1 $R2
done

```
