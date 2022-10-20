library(dplyr)
library(optparse)

option_list <- list(
  make_option(c("-i", "--input"), type="character", default=NULL, help="Input file path(annotated)"),
  make_option(c("-o", "--output"), type="character", default=NULL, help="Output file path")
)

parseobj = OptionParser(option_list=option_list)
opt = parse_args(parseobj)

segs <- read.table(opt$input, sep = '\t')
segs$V1 <- gsub('cycles.txt:', '', segs$V1)
segs$V6 <- paste0(segs$V1, segs$V2)
amplicon_segments <- data.frame(segs$V6, segs$V3, segs$V4, segs$V5)
colnames(amplicon_segments) <- c("segment_barcode", "chr", "start", "end")
#write.table(amplicon_segments,"/Users/heesuk/Projects/NeoantigenPrediction/phd/amplicon_segments.txt", quote = F, col.names = T, row.names = F)

amplicon_segments_start <- data.frame(amplicon_segments$chr, amplicon_segments$start)
amplicon_segments_end <- data.frame(amplicon_segments$chr, amplicon_segments$end)
colnames(amplicon_segments_start) <- c("chr", "pos")
colnames(amplicon_segments_end) <- c("chr", "pos")
segment_positions <- rbind(amplicon_segments_start, amplicon_segments_end) %>% unique()
segment_positions$pos <- segment_positions$pos+1
write.table(segment_positions,opt$output, quote = F, col.names = F, row.names = F)
