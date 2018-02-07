
# -appl CDD,COILS,Gene3D,HAMAP,MobiDBLite,PANTHER,Pfam,PIRSF,PRINTS,ProDom,PROSITEPATTERNS,PROSITEPROFILES,SFLD,SMART,SUPERFAMILY,TIGRFAM

# annotation with interproscan
~/pipelines/common/scripts/interproscan.sh \
  /data/scratch/deakig/blackcurrant/genome \
  ribes.protein.fasta \
  /data/scratch/deakig/blackcurrant/genome/temp/

# restarting interproscan
~/pipelines/common/scripts/restart_interproscan.sh \
 /data/scratch/deakig/blackcurrant/genome \
 ribes.protein.fasta \
 /data/scratch/deakig/blackcurrant/genome/temp/ \
 -appl CDD,COILS,HAMAP,MobiDBLite,Pfam,PIRSF,PRINTS,ProDom,PROSITEPATTERNS,PROSITEPROFILES,SFLD,SMART,SUPERFAMILY,TIGRFAM \
 -iprlookup \
 -goterms \
 -pa \
 -dra
