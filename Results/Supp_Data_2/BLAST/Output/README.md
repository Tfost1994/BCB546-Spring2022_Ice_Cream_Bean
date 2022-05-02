# README

### Directory
`BCB546-Spring2022_Ice_Cream_Bean/Results/Supp_Data_2/Output`  

Contains files resulting from running code to replicate Supplemental file 2.
## Required Code
Objects generated in this directory originate from code file

1. `../../../../Code/Supp_Data_2.md`

`Supp_Data_2.md` depends on `../../../../data_files/Arabidopsis_Flowering_Protein_Seq.fasta`. Files in this directory are generated in naming order using `Supp_Data_2`.

## Object descriptions

1. `1_HV_blast.tsv`: tab-deliminated result of initial blast of query `Arabidopsis_Flowering_Protein_Seq.fasta` on `../HVdb/`  
2. `1_TA_blast.tsv`:tab-deliminated result of initial blast of query `Arabidopsis_Flowering_Protein_Seq.fasta` on `../TAdb/`  
3. `2_HV_Flowering_Prot.fasta`: fasta protein sequences of genes identified in `1_HV_blast.tsv`
4. `2_TA_Flowering_Prot.fasta`: fasta protein sequences of genes identified in `1_TA_blast.tsv`
5. `3_HVonAT_Recip_blast.tsv`: tab-deliminated result of reciprocal blast of query `2_HV_Flowering_Prot.fasta` on `../ATdb/`    
6. `3_TAonAT_Recip_blast.tsv`: tab-deliminated result of reciprocal blast of query `2_TA_Flowering_Prot.fasta` on `../ATdb/`  
7. `4_HV_blast_names.txt`: names of putative ortholog pairs from `1_HV_blast.tsv`  
8. `4_TA_blast_names.txt`: names of putative ortholog pairs from `1_TA_blast.tsv`  
9. `5_HV_recip_match_names.txt`: names of putative ortholog pairs from `2_HV_Flowering_Prot.fasta`  
10. `5_TA_recip_match_names.txt`: names of putative ortholog pairs from `2_TA_Flowering_Prot.fasta`  
11. `6_HV_OrthoMCL.fasta`: fasta protein sequences of putative ortholog genes common to `4_HV_blast_names.txt` and `5_HV_recip_match_names.txt`  
12. `6_TA_OrthoMCL.fasta`: fasta protein sequences of putative ortholog genes common to `4_TA_blast_names.txt` and `5_TA_recip_match_names.txt`  
13. `README.md`: Current file
