# README

### Directory
`BCB546-Spring2022_Ice_Cream_Bean/Results/Fig_2`  

Contains intermediate and output files from running Figure 2 code.
## Required Code
Files generated in this folder originate from two code files.

1. `../../Code/Fig_2.md`

`Fig_2.md` was used to copy in previous alignments from `../Fig_1` into `./Fig_2` as .nex files and it details the generation of .xml files located in this directory using beauti. All files located in the `./Fig2/Output` subdirectory were also generated using `Fig_2.md`.

2. `../../Code/Fig_2.Rmd`

`Fig_2.Rmd` was used to generate the .png files located in this directory. The ggTree package in R was used to create the phylogenic trees depicted in the .png files.

## Object descriptions

`Output/`: subdirectory containing intermediate files  
`Fig1a_Seq.nex`: sequence alignment file in nexus format; required input for beauti  
`Fig1b_Seq.nex`: sequence alignment file in nexus format; required input for beauti  
`Fig1a_Seq.xml`: output of Fig1a_Seq.nex from beauti; required input for beast  
`Fig1b_seq.xml`: output of Fig1b_Seq.nex from beauti; required input for beast  
`README.md`: Current file
