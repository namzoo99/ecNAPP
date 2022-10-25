#!bin/bash

cat ${1}/${2}_POSmerged.txt | awk '{print $1}' > ${1}/for_unique 

sort ${1}/for_unique | uniq > ${1}/unique_2.txt

cat ${1}/unique_2.txt | while read -r line;
do
    grep "^$line" ${1}/${2}_POSmerged.txt > ${1}/$line.txt

    cat ${1}/$line.txt | sort -t ' ' -k2n | sed -n '1p' > ${1}/$line.min
    cat ${1}/$line.txt | sort -t ' ' -k2n | sed -n '$p' > ${1}/$line.max

    cat ${1}/$line.max |  awk '{print $2}' > ${1}/$line.onlymax

    sed 's/chr//' ${1}/$line.min > ${1}/$line.nochrmin

    cat ${1}/$line.nochrmin | sed -e 's/ /\t/g' > ${1}/$line.tabmin


    paste ${1}/$line.tabmin ${1}/$line.onlymax > ${1}/${2}_$line.finally.bed   

    cat ${1}/*.finally.bed | sort -u > ${1}/${2}_svaba_regions.bed

done 

