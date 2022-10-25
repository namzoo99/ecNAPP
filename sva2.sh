#!bin/bash

cat ${1}/${2}_BP.bed |  awk '{print $1, $2}' > ${1}/${2}_startPOS.txt
cat ${1}/${2}_BP.bed |  awk '{print $3, $4}' > ${1}/${2}_endPOS.txt

cat ${1}/${2}_startPOS.txt ${1}/${2}_endPOS.txt > ${1}/${2}_POSmerged
sed 's/chr//' ${1}/${2}_POSmerged > ${1}/${2}_POSmerged.txt

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

    paste ${1}/$line.tabmin ${1}/$line.onlymax > ${1}/${2}_$line.final.bed   
    cat ${1}/${2}_$line.final.bed >> ${1}/${2}_final.chr.bedp
    
done

cat ${1}/${2}_final.chr.bedp | while IFS=$'\t' read -r col1 col2 col3;

do

     echo $col1, $col2, $col3

        if [ `expr ${col2} - 1000`  -lt  0 ];then

         min=1

        else
     
         min=`expr ${col2} - 1000`
         fi

    

    #chr1
    if [[ ${col1}==1 ]] && [[ `expr ${col3} + 1000` -gt 248956422 ]]; then
        max=248956422 
    elif [[ ${col1}==1 ]] && [[ `expr ${col3} + 1000` -gt 248956422 ]]; then
        max=`expr ${col3} + 1000`
    #chr2
    elif [[ ${col1}==2 ]] && [[ `expr ${col3} + 1000` -gt 242193529 ]];then
        max=242193529
    elif [[ ${col1}==2 ]] && [[ `expr ${col3} + 1000` -lt 242193529 ]];then
        max=`expr ${col3} + 1000`
    #chr3
    elif [[ ${col1}==3 ]] && [[ `expr ${col3} + 1000` -gt 198295559 ]];then
        max=198295559
    elif [[ ${col1}==3 ]] && [[ `expr ${col3} + 1000` -lt 198295559 ]];then
        max=`expr ${col3} + 1000`
    #chr4
    elif [[ ${col1}==4 ]] && [[ `expr ${col3} + 1000` -gt 190214555 ]];then
        max=190214555
    elif [[ ${col1}==4 ]] && [[ `expr ${col3} + 1000` -lt 190214555 ]];then
        max=`expr ${col3} + 1000`
    #chr5
    elif [[ ${col1}==5 ]] && [[ `expr ${col3} + 1000` -gt 181538259 ]];then
        max=181538259
    elif [[ ${col1}==5 ]] && [[ `expr ${col3} + 1000` -lt 181538259 ]];then
        max=`expr ${col3} + 1000`
    #chr6
    elif [[ ${col1}==6 ]] && [[ `expr ${col3} + 1000` -gt 170805979 ]];then
        max=170805979
    elif [[ ${col1}==6 ]] && [[ `expr ${col3} + 1000` -lt 170805979 ]];then
        max=`expr ${col3} + 1000`
    #chr7
    elif [[ ${col1}==7 ]] && [[ `expr ${col3} + 1000` -gt 159345973 ]];then
        max=159345973
    elif [[ ${col1}==7 ]] && [[ `expr ${col3} + 1000` -lt 159345973 ]];then
        max=`expr ${col3} + 1000`
    #chr8
    elif [[ ${col4}=8 ]] && [[ `expr ${col3} + 1000` -gt 145138636 ]];then
        max=145138636
    elif [[ ${col4}=8 ]] && [[ `expr ${col3} + 1000` -lt 145138636 ]];then
        max=`expr ${col3} + 1000`
    #chr9
    elif [[ ${col1}==9 ]] && [[ `expr ${col3} + 1000` -gt 138394717 ]];then
        max=138394717
    elif [[ ${col1}==9 ]] && [[ `expr ${col3} + 1000` -lt 138394717 ]];then
        max=`expr ${col3} + 1000`
    #chr10
    elif [[ ${col1} -eq 10 ]] && [[ `expr ${col3} + 1000` -gt 133797422 ]];then
        echo ${col3}
        max=133797422
    elif [[ ${col1} -eq 10 ]] && [[ `expr ${col3} + 1000` -lt 133797422 ]];then
        echo ${col3}
        max=`expr ${col3} + 1000`
    #chr11
    elif [[ ${col1}==11 ]] && [[ `expr ${col3} + 1000` -gt 135086622 ]];then
        max=135086622
    elif [[ ${col1}==11 ]] && [[ `expr ${col3} + 1000` -lt 135086622 ]];then
        max=`expr ${col3} + 1000`
    #chr12
    elif [[ ${col1}==12 ]] && [[ `expr ${col3} + 1000` -gt 133275309 ]];then
        max=133275309
    elif [[ ${col1}==12 ]] && [[ `expr ${col3} + 1000` -lt 133275309 ]];then
        max=`expr ${col3} + 1000`
    #chr13
    elif [[ ${col1}==13 ]] && [[ `expr ${col3} + 1000` -gt 114364328 ]];then
        max=114364328
    elif [[ ${col1}==13 ]] && [[ `expr ${col3} + 1000` -lt 114364328 ]];then
        max=`expr ${col3} + 1000`
    #chr14
    elif [[ ${col1}==14 ]] && [[ `expr ${col3} + 1000` -gt 107043718 ]];then
        max=107043718
    elif [[ ${col1}==14 ]] && [[ `expr ${col3} + 1000` -lt 107043718 ]];then
        max=`expr ${col3} + 1000`
    #chr15
    elif [[ ${col1}==15 ]] && [[ `expr ${col3} + 1000` -gt 101991189 ]];then
        max=101991189
    elif [[ ${col1}==15 ]] && [[ `expr ${col3} + 1000` -lt 101991189 ]];then
        max=`expr ${col3} + 1000`
    #chr16
    elif [[ ${col1}==16 ]] && [[ `expr ${col3} + 1000` -gt 90338345 ]];then
        max=90338345
    elif [[ ${col1}==16 ]] && [[ `expr ${col3} + 1000` -lt 90338345 ]];then
        max=`expr ${col3} + 1000`
    #chr17
    elif [[ ${col1}==17 ]] && [[ `expr ${col3} + 1000` -gt 83257441 ]];then
        max=83257441
    elif [[ ${col1}==17 ]] && [[ `expr ${col3} + 1000` -lt 83257441 ]];then
        max=`expr ${col3} + 1000`
     #chr18
    elif [[ ${col1}==18 ]] && [[ `expr ${col3} + 1000` -gt 80373285 ]];then
        max=80373285
    elif [[ ${col1}==18 ]] && [[ `expr ${col3} + 1000` -lt 80373285 ]];then
        max=`expr ${col3} + 1000`
    #chr19
    elif [[ ${col1}==19 ]] && [[ `expr ${col3} + 1000` -gt 58617616 ]];then
        max=58617616
    elif [[ ${col1}==19 ]] && [[ `expr ${col3} + 1000` -lt 58617616 ]];then
        max=`expr ${col3} + 1000`
    #chr20
    elif [[ ${col1}==20 ]] && [[ `expr ${col3} + 1000` -gt 64444167 ]];then
        max=64444167
    elif [[ ${col1}==20 ]] && [[ `expr ${col3} + 1000` -lt 64444167 ]];then
        max=`expr ${col3} + 1000`
    #chr21
    elif [[ ${col1}==21 ]] && [[ `expr ${col3} + 1000` -gt 46709983 ]];then
        max=46709983
    elif [[ ${col1}==21 ]] && [[ `expr ${col3} + 1000` -lt 46709983 ]];then
        max=`expr ${col3} + 1000`
    #chr22
    elif [[ ${col1}==22 ]] && [[ `expr ${col3} + 1000` -gt 50818468 ]];then
        max=50818468
    elif [[ ${col1}==22 ]] && [[ `expr ${col3} + 1000` -lt 50818468 ]];then
        max=`expr ${col3} + 1000`
    #chrX
    elif [[ ${col1}==X ]] && [[ `expr ${col3} + 1000` -gt 156040895 ]];then
        max=156040895
    elif [[ ${col1}==X ]] && [[ `expr ${col3} + 1000` -lt 156040895 ]];then
        max=`expr ${col3} + 1000`
    #chrY
    elif [[ ${col1}==Y ]] && [[ `expr ${col3} + 1000` -gt 57227415 ]];then
        max=57227415
    elif [[ ${col1}==Y ]] && [[ `expr ${col3} + 1000` -lt 57227415 ]];then
        max=`expr ${col3} + 1000`
    fi

        echo "${col1}   ${min}  ${max}" >> ${1}/${2}_svaba_regions.bed

done
