#!bin/bash
preneospath=${1}
barcode=${2}

                cat ${preneospath}/${barcode}_BP.bed |  awk '{print $1, $2}' > ${preneospath}/${barcode}_startPOS.txt
        cat ${preneospath}/${barcode}_BP.bed |  awk '{print $3, $4}' > ${preneospath}/${barcode}_endPOS.txt

        cat ${preneospath}/${barcode}_startPOS.txt ${preneospath}/${barcode}_endPOS.txt > ${preneospath}/${barcode}_POSmerged
        sed 's/chr//' ${preneospath}/${barcode}_POSmerged > ${preneospath}/${barcode}_POSmerged.txt

                cat ${preneospath}/${barcode}_POSmerged.txt | while IFS=' ', read -r col1 col2
                do
                        bp=`expr ${col2} + 1`

                        echo "${col1}   ${bp}" >> ${preneospath}/breakpoints_from_graphs.all.txt
                done

                cat ${preneospath}/breakpoints_from_graphs.all.txt | sort -u > ${preneospath}/${barcode}.processed.bps
