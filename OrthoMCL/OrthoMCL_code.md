# orthoMCL

OrthoMCL/ directory contained in the GitHub repository does not contain all the files used to generate the results in output_data. Several .fasta files generated in initial data formatting steps are included as files located in `OrthoMCL/original/` and `OrthoMCL/complaintFasta/`. However these files can also be generated in from the `FASTA formatting` section.

Much of the below commands were copied or adapted directly from the OrthoMCL tutorial from (bioinformaticsworkbook.org)[https://bioinformaticsworkbook.org/phylogenetics/00-finding-orthologs-uisng-orthoMCL.html#gsc.tab=0].

## FASTA formatting
```
mkdir OrthoMCL
cp ./blast/TA_OrthoMCL.fasta ./OrthoMCL
cp ./blast/HV_OrthoMCL.fasta ./OrthoMCL
cp ./blast/AT_prot.fasta ./OrthoMCL

cd BCB546-Spring2022_Ice_Cream_Bean/OrthoMCL/

for fasta in ./raw/*.fasta; do
cut -f 1 -d " " $fasta > ${fasta%.*}.temp;
mv ${fasta%.*}.temp $fasta
done

mkdir -p original complaintFasta
mv *.fasta original/
```
Above steps were those used to generate .fasta files contained in the GitHub repository. Files associated with below steps (with the exception of the output_data directory) are not included in repository due to size.

## Setup to use OrthoMCL
```
module load dafoam/1.0
module load orthomcl
module load singularity
singularity pull --name orthomcl.simg shub://ISU-HPC/orthomcl
```
The below line will return warning and fatal lines. The rest of the code still works despite this. The orthomcl.simg file is a required in a later step so it is still included.
```
singularity shell orthomcl.simg
```
## Create Files used in OrthoMCL analysis
```
cd complaintFasta
for fasta in ../original/*.fasta; do
orthomclAdjustFasta $(basename ${fasta%.*}) ${fasta} 1
done

cd ..
orthomclFilterFasta complaintFasta 10 20

module load ncbi-blast
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

module load singularity
singularity pull --name mysql.simg shub://ISU-HPC/mysql

mkdir -p ${PWD}/mysql/var/lib/mysql ${PWD}/mysql/run/mysqld
```
Log out of hpc-class and log back in. This is necessary to start new singularity instance. Under other circumstances using `exit` would exit the singularity shell which failed to run in the above code. However, the orthomcl.simg singularity seems to have only partially initialized. Another singularity cannot be initialized without out exiting the first one, but the use of `exit` exits the remote access rather than the singularity instance.
```
exit
```
Upon logging back in reload modules and start new mysql singularity.
```
module load dafoam/1.0
module load orthomcl

cd BCB546-Spring2022_Ice_Cream_Bean/OrthoMCL/

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

```
To exit the singularity shell
```
exit
```
To end the instance
```
singularity instance stop mysql
```
The normal "$" terminal start should reappear after exiting & stopping.

## Clustering in OrthoMCL
```
module load mcl

for i in $(seq 0.0 0.5 6.0); do
mcl mclInput --abc -I ${i} -o ./output_data/groups_${i}.txt;
orthomclMclToGroups OG${i}_ 1000 < ./output_data/groups_${i}.txt > ./output_data/named_groups_${i}.txt;
done

git clone git@github.com:ISUgenomics/common_scripts.git
cp ../../common_scripts/CopyNumberGen.sh ./
cp ../../common_scripts/ExtractSCOs.sh ./
cp ../../common_scripts/ExtractSeq.sh ./

chmod a+x ./CopyNumberGen.sh
chmod a+x ./ExtractSCOs.sh
chmod a+x ./ExtractSeq.sh

for i in $(seq 0.0 0.5 6.0); do
./CopyNumberGen.sh ./output_data/named_groups_${i}.txt > ./output_data/named_groups_${i}_freq.txt;
done

for n in $(seq 0.0 0.5 6.0); do
awk '{
  if($2 > 0)
  print $1
  }' ./output_data/named_groups_${n}_freq.txt | grep -f - ./output_data/named_groups_${n}.txt  >./output_data/named_groups_${n}_AT.txt
done

```
Inspect *_AT.txt files. Here there was little difference between inflation values 0.0-6.0 so 1.5 was used. Under other circumstances select the number which has the best clustering and specify it as a substitute for i.
```
for i in 1.5; do
cp ./output_data/named_groups_${i}_AT.txt ./named_groups_${i}_scos.txt
./ExtractSeq.sh -o orthogroups named_groups_${i}_scos.txt  goodProteins.fasta
done

```
