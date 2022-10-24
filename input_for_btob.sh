#!/bin/bash
path=${1}
barcode=${2}
out=${3}
END=100

echo "path is ${1} and barcode is ${2}"


for i in $(seq 1 $END); do
if [ -e ${path}/${barcode}_amplicon${i}.png ]; then
    echo "${barcode}    ${path}/${barcode}_amplicon${i}_cycles.txt    ${path}/${barcode}_amplicon${i}_graph.txt" >> ${out}/${barcode}-bp.input.txt
else
	exit 2
fi
done
