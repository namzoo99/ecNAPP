#!bin/bash

grep "Interval" ${1}/*_cycles.txt | while IFS='	', read -r col1 col2 col3 col4 col5
do echo -e "chr${col3}:${col4}\t${col5}" >> ${1}/bp_to_bed_regions
done


i='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X Y'
for i in ${i}; do
cat ${1}/bp_to_bed_regions | sort -u | grep "chr${i}:" > ${1}/chr_${i}

cat ${1}/chr_${i} | sed  's/:/	/g' | while IFS='	', read -r col1 col2 col3
do
        echo -e "${col2}\n${col3}" >>  ${1}/min-max-chr-${i}
	sort -n ${1}/min-max-chr-${i} > ${1}/sort-chr-${i}
done


if [ -e ${1}/sort-chr-${i} ]; then
        min=`sed -n '1p' ${1}/sort-chr-${i}`
        max=`sed -n '$p' ${1}/sort-chr-${i}`
        echo -e "chr${i}:${min}-${max}" >> ${2}/intervals	
fi

done

cat ${2}/intervals | tr "\n" " " > ${2}/intervals_inline
sort -u ${2}/intervals_inline > ${2}/intervals_for_bp.txt

rm ${1}/chr_* ${1}/sort-chr-* ${1}/min-max-chr-*
