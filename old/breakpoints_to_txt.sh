#!bin/bash
aapath=${1}
outpath=${2}
barcode=${3}
if [ "${aapath}" == "" ]; then
	echo "Input error:You must provide the path/of/AA_results ! (Don't write -i)"
else

grep "discordant" ${aapath}/*_graph.txt | awk -F '\t' '{print $1 $2}' | sed 's/.*'\t'//' > ${aapath}/name_pos3
cat ${aapath}/name_pos3 | sed 's/->/\
/' > ${aapath}/name_pos1

cat ${aapath}/name_pos1 | sed 's/+//g; s/-//g; s/:/	/g' > ${aapath}/breakpoints_from_graphs.minus1.txt


cat ${aapath}/breakpoints_from_graphs.minus1.txt | while IFS='	', read -r col1 col2
do 
	bp=`expr ${col2} + 1`
	echo "${col1}	${bp}" >> ${2}/breakpoints_from_graphs.all.txt
done

cat ${outpath}/breakpoints_from_graphs.all.txt | sort -u > ${outpath}/${barcode}.processed.bps

rm  ${aapath}/name_pos3  ${aapath}/name_pos1 ${outpath}/breakpoints_from_graphs.all.txt

fi
