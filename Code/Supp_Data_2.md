# Ortholog Group Analysis

HPC-class at Iowa State was used. This is an HPC with ncbi-blast and OrthoMCL already installed. If using on a local machine follow installation instructions on  the [NCBI website](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) and the [OrthoMCL user guide](https://orthomcl.org/common/downloads/software/v2.0/UserGuide.txt).

## Gene identification with using BLASTP & reciprocal BlASTP

Navigate to git repository. Result of pwd should be end in "/BCB546-Spring2022_Ice_Cream_Bean"
```
pwd
```
If using a HPC, load required modules.
```
module load dafoam
module load ncbi-blast/2.4.0+
```
Create directories to organize data
```
mkdir -p ./Results/Supp_Data_2/BLAST/TAdb ./Results/Supp_Data_2/BLAST/HVdb ./Results/Supp_Data_2/BLAST/ATdb ./Results/Supp_Data_2/BLAST/Output
```
The TAIR [bulk data retrieval tool](https://www.arabidopsis.org/tools/bulk/sequences/index.jsp) was to obtain gene sequences listed in Supplemental Data 1. A method other than using the GUI website interface was not apparent. No Arabidopsis genome version was listed in the paper so the Araport11 coding sequences data set was used. One sequence per locus query option was also used and data were output to a fasta file and saved as `Arabidopsis_Flowering_Protein_Seq.fasta` at /BCB546-Spring2022_Ice_Cream_Bean/Results/Data_Files. The 14 miRNA locus IDs were not found using this search.
```
cp ./Results/Data_Files/Arabidopsis_Flowering_Protein_Seq.fasta  ./Results/Supp_Data_2/BLAST/
```
The data based used in the reciprocal BLAST searches were obtained from Ensembl. Release 26 was used as in Peng et al. (2015). URL information can be obtained from [Ensembl Plant FTP](http://ftp.ensemblgenomes.org/pub/plants/). Rsync scripting information was obtained from [Ensembl Plant Info](https://plants.ensembl.org/info/data/ftp/rsync.html)
```
rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/hordeum_vulgare/pep/ ./Results/Supp_Data_2/BLAST/HVdb

rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/triticum_aestivum/pep/ ./Results/Supp_Data_2/BLAST/TAdb

rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/arabidopsis_thaliana/pep/ ./Results/Supp_Data_2/BLAST/ATdb
```
Create database from .fa.gz files downloaded in previous step using makeblastdb
```
cd Results/Supp_Data_2/BLAST/

gunzip -c TAdb/Triticum_aestivum.IWGSC2.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Triticum_aestivum_db -dbtype prot -out ./TAdb/TAdb

gunzip -c ./HVdb/Hordeum_vulgare.082214v1.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Hordeum_vulgare_db -dbtype prot -out ./HVdb/HVdb

gunzip -c ./ATdb/Arabidopsis_thaliana.TAIR10.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Arabidopsis_thaliana_db -dbtype prot -out ATdb/ATdb
```
An interactive session was started on the HPC to perform blast searches.
```
salloc -n 1 -t 2:00:00
```
Blast for barley and wheat protein sequences using Arabidopsis flowering genes identified from TAIR.
```
blastp -query Arabidopsis_Flowering_Protein_Seq.fasta -task blastp -db ./TAdb/TAdb -out ./Output/1_TA_blast.tsv -evalue 1e-5 -outfmt 6
blastp -query Arabidopsis_Flowering_Protein_Seq.fasta -task blastp -db ./HVdb/HVdb -out ./Output/1_HV_blast.tsv -evalue 1e-5 -outfmt 6
```
Retrieve Triticum aestivum and Hordeum vulgare sequences identified in the first blastp to use as queries for a reciprocal blast on the Arabidopsis thaliana proteome.
```
awk '{print $2}' ./Output/1_TA_blast.tsv | sort | uniq | blastdbcmd -db ./TAdb/TAdb -entry_batch - -outfmt "%f" >./Output/2_TA_Flowering_Prot.fasta
awk '{print $2}' ./Output/1_HV_blast.tsv | sort | uniq | blastdbcmd -db ./HVdb/HVdb -entry_batch - -outfmt "%f" >./Output/2_HV_Flowering_Prot.fasta
```
Perform reciprocal blastp. Only taking the top 3 results as performed in Peng et al. (2015).
```
blastp -query ./Output/2_TA_Flowering_Prot.fasta -task blastp-fast -db ./ATdb/ATdb -out ./Output/3_TAonAT_Recip_blast.tsv -evalue 1e-5 -outfmt 6 -max_target_seqs 3
blastp -query ./Output/2_HV_Flowering_Prot.fasta -task blastp -db ./ATdb/ATdb -out ./Output/3_HVonAT_Recip_blast.tsv -evalue 1e-5 -outfmt 6 -max_target_seqs 3
```
Get Triticum aestivum & Hordeum vulgare genes which have same Arabidopsis thaliana gene in top 3 results of reciprocal search. Paper appears to have not considered the .# at the end of gene names when preforming these searches.

Create list from the original blast search to match the reciprocal blast results against.
```
awk '{print $2"\t"$1}' ./Output/1_TA_blast.tsv | sort | uniq >./Output/4_TA_blast_names.txt
awk '{print $2"\t"$1}' ./Output/1_HV_blast.tsv | sort | uniq >./Output/4_HV_blast_names.txt
```
Grep to match original against reciprocal using the 4_*_blast_names.txt files
```
grep -Ff ./Output/4_TA_blast_names.txt ./Output/3_TAonAT_Recip_blast.tsv | awk {'print $1'} | sort | uniq | sort -k2 >./Output/5_TA_recip_match_names.txt

grep -Ff ./Output/4_HV_blast_names.txt ./Output/3_HVonAT_Recip_blast.tsv | awk {'print $1'} | sort | uniq | sort -k2 >./Output/5_HV_recip_match_names.txt
```
Retrieve the identified protein sequences from the Triticum aestivum and Hordeum vulgare protein databases.
```
blastdbcmd -db ./TAdb/TAdb -entry all -outfmt "%f" | grep -f ./Output/5_TA_recip_match_names.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./TAdb/TAdb -entry_batch - -outfmt "%f" >./Output/6_TA_OrthoMCL.fasta

blastdbcmd -db ./HVdb/HVdb -entry all -outfmt "%f" | grep -f ./Output/5_HV_recip_match_names.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./HVdb/HVdb -entry_batch - -outfmt "%f" >./Output/6_HV_OrthoMCL.fasta
```
Files used with OrthoMCL included 6_TA_OrthoMCL.fasta, 6_HV_OrthoMCL.fasta, and Arabidopsis_Flowering_Protein_Seq.fasta. Files are included in `data_files` directory in case of difficulty with above code but generated files located in `Results/Supp_Data_2/BLAST/Output`should be the same and this path is used in the below code.

# OrthoMCL

OrthoMCL was used through Iowa State University's HPC-class. OrthoMCL was already installed. If using on a local machine, follow installation instructions at

OrthoMCL/ directory contained in the GitHub repository does not contain all the files used to generate the results in Output. Several .fasta files generated in initial data formatting steps are included as files located in `OrthoMCL/original/` and `OrthoMCL/complaintFasta/`. However these files can also be generated in from the `FASTA formatting` section.

Much of the below commands were copied or adapted directly from the OrthoMCL tutorial from [bioinformaticsworkbook.org](https://bioinformaticsworkbook.org/phylogenetics/00-finding-orthologs-uisng-orthoMCL.html#gsc.tab=0).

## FASTA formatting
```
cd ../../Supp_Data_2

mkdir -p OrthoMCL/fasta OrthoMCL/complaintFasta

cp ./BLAST/Output/6_TA_OrthoMCL.fasta ./OrthoMCL/fasta/
cp ./BLAST/Output/6_HV_OrthoMCL.fasta ./OrthoMCL/fasta/
cp ./BLAST/Arabidopsis_Flowering_Protein_Seq.fasta ./OrthoMCL/fasta/

cd ./OrthoMCL/

for fasta in ./fasta/*.fasta; do
cut -f 1 -d " " $fasta > ${fasta%.*}.temp;
mv ${fasta%.*}.temp $fasta
done
```
Above steps were those used to generate .fasta files contained in the GitHub repository. Files associated with below steps (with the exception of the Output directory) are not included in repository due to size.

## Setup to use OrthoMCL
On HPC-class start an interactive session
```
salloc -N 1 -t 2:00:00
```
## Create Files used in OrthoMCL analysis
Load modules and start singularity
```
module load dafoam/1.0
module load orthomcl
module load singularity
singularity pull --name orthomcl.simg shub://ISU-HPC/orthomcl
singularity shell orthomcl.simg
```
If using HPC-class, a number of perl warning messages appear. It seems to be a problem associated with difference in directory settings while using the HPC. Ouput files seem to write without issue despite this.
```
cd complaintFasta
for fasta in ../fasta/*.fasta; do
orthomclAdjustFasta $(basename ${fasta%.*}) ${fasta} 1
done

cd ..
orthomclFilterFasta complaintFasta 10 20

exit
```
The singularity terminal should no longer be active before proceeding.
```
makeblastdb -in goodProteins.fasta -dbtype prot -parse_seqids -out goodProteins.fasta

blastp -db goodProteins.fasta -query goodProteins.fasta -outfmt 6 -evalue 1e-5 -out blastp.tsv -num_threads 4

orthomclBlastParser blastp.tsv ./complaintFasta/ >> similarSequences.txt
```
## mySQL set up
OrthoMCL requires a the use of a database to run the analysis.

When creating the orthomcl.config, the percent match cut-off and e-values are set per the paper's designation.
```
cat > orthomcl.config <<END
dbVendor=mysql
dbConnectString=dbi:mysql:orthomcl:mysql_local_infile=1:localhost:3306
dbLogin=root
dbPassword=my-secret-pw
similarSequencesTable=SimilarSequences
orthologTable=Ortholog
inParalogTable=InParalog
coOrthologTable=CoOrtholog
interTaxonMatchView=InterTaxonMatch
percentMatchCutoff=50
evalueExponentCutoff=-5
oracleIndexTblSpc=NONE
END

singularity pull --name mysql.simg shub://ISU-HPC/mysql

mkdir -p ${PWD}/mysql/var/lib/mysql ${PWD}/mysql/run/mysqld

singularity instance start --bind ${HOME} \
--bind ${PWD}/mysql/var/lib/mysql/:/var/lib/mysql \
--bind ${PWD}/mysql/run/mysqld:/run/mysqld \
./mysql.simg mysql

singularity run instance://mysql
```
The $ line will not return after running the above line. Enter the next line after a few seconds when cursor stops blinking.
```
singularity exec instance://mysql mysqladmin create orthomcl

singularity shell --bind $PWD \
  --bind ${PWD}/mysql/run/mysqld:/run/mysqld \
  ./orthomcl.simg
```
These may throw perl errors but files will be written anyway. Before running these lines the terminal line should start with "Singularity>".
```
orthomclInstallSchema orthomcl.config

orthomclLoadBlast orthomcl.config similarSequences.txt

orthomclPairs orthomcl.config pairs.log cleanup=no

orthomclDumpPairsFiles orthomcl.config

exit

singularity instance stop mysql
```
The normal "$" terminal start should reappear after exiting & stopping.

## Clustering in OrthoMCL
```
module load mcl

mkdir Output

for i in $(seq 0.0 0.5 6.0); do
mcl mclInput --abc -I ${i} -o ./Output/groups_${i}.txt;
orthomclMclToGroups OG${i}_ 1000 < ./Output/groups_${i}.txt > ./Output/named_groups_${i}.txt;
done

git clone git@github.com:ISUgenomics/common_scripts.git

chmod a+x ./common_scripts/CopyNumberGen.sh
chmod a+x ./common_scripts/ExtractSCOs.sh
chmod a+x ./common_scripts/ExtractSeq.sh

for i in $(seq 0.0 0.5 6.0); do
./common_scripts/CopyNumberGen.sh ./Output/named_groups_${i}.txt > ./Output/named_groups_${i}_freq.txt;
done

for n in $(seq 0.0 0.5 6.0); do
awk '{
  if($4 > 0)
  print $1
  }' ./Output/named_groups_${n}_freq.txt | grep -f - ./Output/named_groups_${n}.txt  >./Output/named_groups_${n}_AT.txt
done

wc -l ./Output/*_AT.txt
```
Returned values shows how many ortholog groups were formed. The lower the values the tighter the clusters should be.

Inspect *_AT.txt files. Here there was little difference between inflation values 0.0-6.0 so 1.5 was used. Under other circumstances select the number which has the best clustering and specify it as a substitute for i.
```
for i in 1.5; do
cp ./Output/named_groups_${i}_AT.txt ./named_groups_${i}_scos.txt
./common_scripts/ExtractSeq.sh -o orthogroups ./Output/named_groups_${i}_AT.txt  goodProteins.fasta
done
```
Fasta files for each orthogroup are written to the orthogroup directory.
