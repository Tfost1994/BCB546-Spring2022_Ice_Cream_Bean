# BLAST and reciprocal BLAST

To install blast+ on a local Ubuntu-based unix system
```
sudo apt-get install ncbi-blast+
```
Navigate to git repository. Result of pwd should be end in "/BCB546-Spring2022_Ice_Cream_Bean"
```
pwd
```
Create directories to organize data
```
mkdir -p ./blast/TA/ ./blast/HV/ ./blast/AT
```
URL information can be obtained from [Ensembl Plant FTP](http://ftp.ensemblgenomes.org/pub/plants/). Beginning of below URLs should remain the same (rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/). The end can be changed based on Index listed on the webpage you navigate to within the [Ensembl Plant FTP](http://ftp.ensemblgenomes.org/pub/plants/).
Rsync information obtained from [Ensembl Plant Info](https://plants.ensembl.org/info/data/ftp/rsync.html)
```
cd ./blast
rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/hordeum_vulgare/pep/ ./HV
rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/triticum_aestivum/pep/ ./TA
rsync -av rsync://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-26/fasta/arabidopsis_thaliana/pep/ ./AT
```
Create database from .fa.gz files downloaded in previous step using makeblastdb
```
cd TA
gunzip -c Triticum_aestivum.IWGSC2.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Triticum_aestivum_db -dbtype prot -out TAdb

cd ../HV
gunzip -c Hordeum_vulgare.082214v1.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Hordeum_vulgare_db -dbtype prot -out HVdb

cd ../AT
gunzip -c Arabidopsis_thaliana.TAIR10.26.pep.all.fa.gz | makeblastdb -parse_seqids -in - -title Arabidopsis_thaliana_db -dbtype prot -out ATdb
```
Used TAIR [bulk data retrieval tool](https://www.arabidopsis.org/tools/bulk/sequences/index.jsp) to obtain gene sequences listed in Supplemental Data 1. No Arabidopsis genome version was listed in the paper so the Araport11 coding sequences data set was used. One sequence per locus query option was also used and data were output to a fasta file and saved as `AT_prot.fasta` at /BCB546-Spring2022_Ice_Cream_Bean/blast. The 14 miRNA locus IDs were not found using this search.


Blast for barley and wheat protein sequences using Arabidopsis flowering genes
```
blastp -query AT_prot.fasta -task blastp -db ./TA/TAdb -out TA_blast.tsv -evalue 1e-5 -outfmt 6
blastp -query AT_prot.fasta -task blastp -db ./HV/HVdb -out HV_blast.tsv -evalue 1e-5 -outfmt 6
```
retrieve sequences for reciprocal blast
```
mkdir reciprocal_HV reciprocal_TA
awk '{print $2}' TA_blast.tsv | sort | uniq | blastdbcmd -db ./TA/TAdb -entry_batch - -outfmt "%f" >./reciprocal_TA/TA_flowering.fasta
awk '{print $2}' HV_blast.tsv | sort | uniq | blastdbcmd -db ./HV/HVdb -entry_batch - -outfmt "%f" >./reciprocal_HV/HV_flowering.fasta
```
perform reciprocal blastp
```
blastp -query ./reciprocal_TA/TA_flowering.fasta -task blastp-fast -db ./AT/ATdb -out ./reciprocal_TA/AT_TA_blast.tsv -evalue 1e-5 -outfmt 6 -max_target_seqs 3
blastp -query ./reciprocal_HV/HV_flowering.fasta -task blastp -db ./AT/ATdb -out ./reciprocal_HV/AT_HV_blast.tsv -evalue 1e-5 -outfmt 6 -max_target_seqs 3
```
Get Triticum aestivum & Hordeum vulgare genes which have same Arabidopsis thaliana gene in top 3 results of reciprocal search. Paper appears to have not considered the .# at the end of gene names when preforming these searches.

Create list from the original TA blast search to match reciprocal against
```
awk '{print $2"\t"$1}' TA_blast.tsv | sort | uniq >./reciprocal_TA/TA_match.txt
awk '{print $2"\t"$1}' HV_blast.tsv | sort | uniq >./reciprocal_HV/HV_match.txt

```
Grep to match original against reciprocal using the new names
```
grep -Ff ./reciprocal_TA/TA_match.txt ./reciprocal_TA/AT_TA_blast.tsv | awk {'print $1'} | sort | uniq | sort -k2 >TA_reciprocal_match_genenames.txt

grep -Ff ./reciprocal_HV/HV_match.txt ./reciprocal_HV/AT_HV_blast.tsv | awk {'print $1'} | sort | uniq | sort -k2 >HV_reciprocal_match_genenames.txt
```
```
blastdbcmd -db ./TA/TAdb -entry all -outfmt "%f" | grep -f TA_reciprocal_match_genenames.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./TA/TAdb -entry_batch - -outfmt "%f" >TA_OrthoMCL.fasta

blastdbcmd -db ./HV/HVdb -entry all -outfmt "%f" | grep -f HV_reciprocal_match_genenames.txt - | awk '{print $1}' | sed 's/^>//' | blastdbcmd -db ./HV/HVdb -entry_batch - -outfmt "%f" >HV_OrthoMCL.fasta
```
Used TA_OrthoMCL.fasta, HV_OrthoMCL.fasta, and AT_prot.fasta for OrthoMCL in HPC class. Files were transferred by cloning the repository onto HPC-Class. Continue with the .md file located in the OrthoMCL directory.
