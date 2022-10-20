#!/bin/bash

while getopts b:p:o: flag
do 
case "${flag}" in
        b) barcode=${OPTARG};;
        p) svabapath=${OPTARG};;
        o) output=${OPTARG};;
    esac
done


## Find breakpoints from AA that match svaba 
cat ${output}/${barcode}.processed.bps | while read line
        do
        grep -w "$line" ${svabapath}/${barcode}.svaba.unfiltered.sv.vcf >> ${output}/breakpoint.svaba
        echo "$line done"
        done


## Trim only contigs to match alignment.txt
cat ${output}/breakpoint.svaba | awk '{print $8}' | grep -o "SCTG.*[A-Z];" > ${output}/bp.contigs
echo "contigs extracted..."

sed "s/SCTG=//; s/;//" ${output}/bp.contigs > ${output}/${barcode}.contigs.txt
#rm bp.contigs
echo "done!"

## Find contigs from alignment.txt
tar -zxf ${svabapath}/${barcode}.alignments.txt.gz
cat ${output}/${barcode}.contigs.txt | while read line
do
        echo "looking for $line ..."
        awk -v RS="" -v ORS="\n\n" "/$line/" ${svabapath}/${barcode}.alignments.txt >> ${output}/${barcode}.bps-align.txt
	echo "$line done"
done

## Organize the alignments to only contig reference sequence
awk '{if(index($2,"c_")!=0) print $0 }' ${output}/${barcode}.bps-align.txt > ${output}/EQEPOC.txt
sed '/||/d' ${output}/EQEPOC.txt > ${output}/EQEPOC_filtered.txt
cat ${output}/EQEPOC_filtered.txt | awk '{print $1}' > ${output}/only1.txt
cat ${output}/EQEPOC_filtered.txt | awk '{print $2}' > ${output}/only2.txt
awk '{print ">"$0}' ${output}/only2.txt > ${output}/only2_added.txt
paste ${output}/only2_added.txt ${output}/only1.txt > ${output}/changed.txt
sed 's/\t/\n/g' ${output}/changed.txt > ${output}/${barcode}.fasta.txt

rm ${output}/EQEPOC.txt ${output}/EQEPOC_filtered.txt ${output}/only1.txt ${output}/only2.txt ${output}/only2_added.txt ${output}/changed.txt

