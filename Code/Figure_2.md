#Phylogenetic Analysis

HPC-class needs to be logged into allowing X11 forwarding to use some of the BEAST program functionalities. The -Y option needs to be used when logging in.

If the user is working on a local machine with BEAST properly installed this should not be a concern.
```
ssh -Y [UserID]@hpc-class.its.iastate.edu
```
Current directory should contain BCB546-Spring2022_Ice_Cream_Bean directory.
```
cd ./BCB546-Spring2022_Ice_Cream_Bean

mkdir -p ./Results/Fig_2/Output
```
To convert the files output from ClustX, run the below loop in the folder containing the .nxs & .aln files with the same name. Amino acid sequences were used from the .aln file with the header and footer of the .nxs file to generate a .nex file.
```
for file in ./Results/Fig_1/Output/*.aln
do
  for i in $(sed '1,3d' $file | awk '{print $1}' | perl -pe 's;^\s*;;g' | perl -pe 's;^[^A-Z]*$;;g' | sort | uniq)
  do
    aa=$(sed '1,3d' $file | grep $i - | awk '{print $2}' | perl -pe 's;\s+;;g')
    printf "$i \t $aa \n" >>temp.txt
  done
  (head -n 8 $(echo "$file" | sed 's;.aln;.nxs;') ; column -t -s' ' temp.txt ; tail -n 2 $(echo "$file" | sed 's;.aln;.nxs;')) | cat >./Results/Fig_2/$(echo "$file" | sed 's;^.*\/;;' | sed 's;.aln;.nex;')
  rm temp.txt
done
```
Enter an interactive session in a partition with a gpu
```
salloc -n 1 -t 2:00:00 --partition=gpu1
```
Load nessary modules
```
module load dafoam
module load beast/1.8.2
```
Creating an XML file with beauti requires "importing" the .nex file rather than "opening" the file. Because of this, using the GUI is necessary.

The error created when attempting to launch this way can be seen with this command.
```
beauti ./BCB546-Spring2022_Ice_Cream_Bean/phylogenies/Alignments/Fig1a_Seq.nex
```
To open the beauti GUI
```
beauti
```
Use key press ctrl+i to open the import window. Navigate to the ./Results/Fig_2/ directory. Select one *.nex files. Use ctrl+e to generate and XML file using the defaults per the description by Peng et al. (2015). Save results to ./Results/Fig_2/ directory. To delet current file navigate to the `Edit` tab and select `Delete`. Repeat for second file, then exit the GUI window.

The paper says that 1,000,000 generations is default. However 10,000,000 appears to be the default when using beauti. The default was kept rather than changing it to match the paper.
```
cd ./Results/Fig_2/Output

beast ../Fig1a_Seq.xml
beast ../Fig1b_Seq.xml
```
It is unclear how many burn-ins were discarded because the `treeannotator -burnin` requires the exact number to discard rather than the proportion. The number of states was considered to be the same as the default generations used in previous steps so 2,500,000 was used.  
```
treeannotator -burnin 2500000 Fig1a_Seq.trees Fig1a_Seq_out.txt
treeannotator -burnin 2500000 Fig1b_Seq.trees Fig1b_Seq_out.txt
```
