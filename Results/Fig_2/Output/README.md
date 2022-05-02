# README

### Directory
`BCB546-Spring2022_Ice_Cream_Bean/Results/Fig_2/Output`  

Contains intermediate and output files from running Figure 2 code.
## Required Code
Files generated in this folder originate from two code files.

1. `../../../Code/Fig_2.md`

`Fig_2.md` was used to generate .log, .trees, and _output.txt files located in this directory. The program beast was used to generate .log and .trees files. The program treeannotator was used to generate _output.txt files.

## Object descriptions

Fig1a_Seq.log: log file resulting from `../Fig_1a_Seq.xml` in beast;
Fig1b_Seq.log: log file resulting from using `../Fig_1b_Seq.xml` in beast
Fig1a_Seq.trees: tree file resulting from using `../Fig_1a_Seq.xml` in beast; used as input for treeannotator
Fig1b_Seq.trees: tree file resulting from using `../Fig_1b_Seq.xml` in beast; used as input for treeannotator
Fig1a_Seq_out.txt: annotated tree file from using `Fig_1a_Seq.trees` in treeannotator; input for Figure 2b in `../../../Code/Fig_2.Rmd`
Fig1b_Seq_out.txt: annotated tree file from using `Fig_1b_Seq.trees` in treeannotator; input for Figure 2a in `../../../Code/Fig_2.Rmd`
`README.md`: Current file
