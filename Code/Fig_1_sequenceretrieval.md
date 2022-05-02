# Sequences for Figure 1

Find sequences in Ensembl Release 26 based on names in paper.

HPC-class at Iowa State was used. This is an HPC with ncbi-blast already installed. If using on a local machine follow installation instructions on  the [NCBI website](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).

```
module load dafoam
module load ncbi-blast/2.4.0+
```
Starting directory should be `BCB546-Spring2022_Ice_Cream_Bean`.
```
cd ./BCB546-Spring2022_Ice_Cream_Bean
```
A file containing the names of the genes used in Figure 1 copied from the paper is included as the text file `Fig1_names.txt`. Names are line separated.
```
mkdir -p ./Results/Fig_1/Output
cp ./data_files/Fig1_names.txt ./Results/Fig_1/Output
cd ./Results/Fig_1

mkdir Output
sort ./Output/Fig1_names.txt | grep ^Traes - | uniq > ./Output/Fig1_TA_names.txt
sort ./Output/Fig1_names.txt | grep ^MLOC - | uniq > ./Output/Fig1_HV_names.txt
sort ./Output/Fig1_names.txt | grep ^AT - | uniq > ./Output/Fig1_AT_names.txt
```
Make blast databases
```
mkdir ./BLASTdb

rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/hordeum_vulgare/pep/ ./BLASTdb/

rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/triticum_aestivum/pep/ ./BLASTdb/

rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/arabidopsis_thaliana/pep/ ./BLASTdb/

gunzip -c ./BLASTdb/Triticum_aestivum.IWGSC2.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Triticum_aestivum_db -dbtype prot -out ./BLASTdb/TAdb

gunzip -c ./BLASTdb/Hordeum_vulgare.082214v1.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Hordeum_vulgare_db -dbtype prot -out ./BLASTdb/HVdb

gunzip -c ./BLASTdb/Arabidopsis_thaliana.TAIR10.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Arabidopsis_thaliana_db -dbtype prot -out ./BLASTdb/ATdb
```
Get flowering gene protein sequences from databases.

Names in the database include a suffix not included in the figure names so grep is used to find matches.
```
blastdbcmd -db ./BLASTdb/TAdb -entry all -outfmt "%f" | grep -f ./Output/Fig1_TA_names.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./BLASTdb/TAdb -entry_batch - -outfmt "%f" >./Output/Fig_1_Wheat_Protein.fasta

blastdbcmd -db ./BLASTdb/HVdb -entry all -outfmt "%f" | grep -f ./Output/Fig1_HV_names.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./BLASTdb/HVdb -entry_batch - -outfmt "%f" >./Output/Fig_1_Barley_Protein.fasta

blastdbcmd -db ./BLASTdb/ATdb -entry all -outfmt "%f" | grep -f ./Output/Fig1_AT_names.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./BLASTdb/ATdb -entry_batch - -outfmt "%f" >./Output/Fig_1_Arabidopsis_Protein.fasta
