library(readxl)
library(dplyr)
library(stringr)
###There is a bug in a function in the kableExtra package which has not been updated into CRAN yet; 
# must use this version to collapse rows in tables
devtools::install_github(repo="haozhu233/kableExtra", ref="a6af5c0")
library(kableExtra)
library(knitr)
library(tidyr)

setwd("C:/Users/karle/Desktop/BCB546X/Project")

supp1 <- read_xls("Supplemental file 1.xls", skip = 1, n_max = 204)

#Extract Chr & POS from locus name
supp1 <- supp1 %>%
  separate(Locus, into = c("X1", "Chr", "POS"), sep = "[A-Z]+", remove = FALSE)%>%
  select(!X1)

table1 <- data.frame(`Functional group`=pull(distinct(supp1, Group)),
                     AT1 = NA,
                     AT2 = NA,
                     AT3 = NA,
                     AT4 = NA,
                     AT5 = NA)

for(i in 1:nrow(table1)){
  counts <- supp1 %>%
    count(Chr, Group, .drop = FALSE) %>%
    filter(Group == table1[i,1])
  for(j in 1:nrow(counts)){
    chrs <- counts$Chr %>% as.numeric()
    table1[i, (chrs[j]+1)] <- counts$n[j]
  }
}

table1[is.na(table1)] <- 0

#add summing rows & column; add labels; arrange rows
table2 <- table1 %>%
  mutate(Total=rowSums(.[,-1]))%>%
  rbind(c("Subtotal", colSums(.[1:7,2:7]))) %>%
  rbind(c("Total", colSums(sapply(.[1:8,2:7], as.numeric)))) %>%
  mutate(`Gene type` = c(rep("Protein coding", times = 7), "MicroRNA", "Protein coding", "Total"),
         .before = "Functional.group") %>%
  mutate(Order = c(1, 2, 3, 4, 5, 6, 7, 9, 8, 10)) %>%
  arrange(Order) %>%
  select(-9)


#formatting
table2$Functional.group[which(table2$`Gene type`=="MicroRNA")] <- NA
table2$`Gene type`[which(table2$Functional.group=="Total")] <- NA
colnames(table2)[2] <- "Functional Group"

#make table
options(knitr.kable.NA = '')

kable(table2, align = c("l", rep("c", 7)), caption = "Table 1: Distributions of 204 flowering genes over five chromosomes and seven known functional groups in Arabidopsis compiled through searches in the literature and TAIR." ) %>%
  kable_classic(html_font = "Times New Roman") %>%
  collapse_rows(columns = 1) %>%
  row_spec(8, bold = TRUE) %>%
  row_spec(9, extra_css = "border-top: 1px solid;") %>%
  row_spec(10, bold = TRUE, extra_css = "border-top: 1px solid;")
  
##Notes: AT5 photoperiod and flower development have flipped 1 gene in comparison to the paper 

#### Table S1

supp1B <- read_xls("Supplemental file 1.xls", skip = 1, n_max = 204, sheet = 2)

#Extract Chr & POS from locus name
supp1B <- supp1B %>%
  separate(GeneID, into = c("X1", "Chr", "POS"), sep = "[A-Z]+", remove = FALSE)%>%
  select(!X1)

tableS1 <- data.frame(`Functional group`=pull(distinct(supp1B, Group)),
                     AT1 = NA,
                     AT2 = NA,
                     AT3 = NA,
                     AT4 = NA,
                     AT5 = NA)

for(i in 1:nrow(tableS1)){
  counts <- supp1B %>%
    count(Chr, Group, .drop = FALSE) %>%
    filter(Group == tableS1[i,1])
  for(j in 1:nrow(counts)){
    chrs <- counts$Chr %>% as.numeric()
    tableS1[i, (chrs[j]+1)] <- counts$n[j]
  }
}

tableS1[is.na(tableS1)] <- 0

#add summing rows & column; add labels; arrange rows
tableS1 <- tableS1 %>%
  mutate(Total=rowSums(.[,-1]))%>%
  rbind(c("Total", colSums(.[1:7,2:7])))


#formatting
colnames(tableS1)[1] <- "Functional Group"

#make table

kable(tableS1, caption = "Supplemental Table S1 - Distributions of 101 flowering genes over five
chromosomes and seven known functional group in Arabidopsis.") %>%
  kable_classic(html_font = "Times New Roman")


