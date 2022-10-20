library(readr)
library(dplyr)
library(tidyr)
library(optparse)

option_list <- list(
  make_option(c("-i", "--input"), type="character", default=NULL, help="Input file path(annotated)"),
  make_option(c("-o", "--output"), type="character", default=NULL, help="Output file path")
)

parseobj = OptionParser(option_list=option_list)
opt = parse_args(parseobj)

hlas <- read.delim(opt$input, header = F, sep = '\t')
hlas <- t(hlas)
hlas <- hlas[c(2,3),]
hla_final <- gsub("_",":",hlas) %>% toupper() %>% strsplit(.,':')
hla_final <- data.frame( 
            C1 = sapply( hla_final, "[", 1),
            C2 = sapply( hla_final, "[", 2),
            C3 = sapply( hla_final, "[", 3),
            C4 = sapply( hla_final, "[", 4)
            )
hla_final$hla <- paste(hla_final$C1, hla_final$C2, sep = '-')
hla_final$num <- paste(hla_final$C3, hla_final$C4, sep = ':')
final_out <- data.frame(paste(hla_final$hla, hla_final$num, sep = ''))
final_out<-t(final_out)
write.table(final_out, opt$output, row.names = F, col.names = F, quote = F, sep = ',')
