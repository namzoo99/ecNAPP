#!/bin/bash

    echo "
    ###########################################################################
                             
                                    ecNAPP v2.0

                            let's look for neoantigens!

                        created by Harold and Mary of CBM LAB
		
     		        For the use of this script, please prepare
		
		        1) Docker

		        2) mosek license and reference data for AA-suite, svaba

                3) csv file consisted of:
                    - project name
                    - sample barcode
                    - path where docker will bind to (docker -v)
                    - input file directory
                    - reference genome build
                    - working directory where the pipeline will be at
                    - output directory 
                    - directory of reference for svaba (genome)
                    - directory of reference for svaba (dbsnp)
                    - directory of MOSEK license
                    - directory of AA repo


    ##########################################################################
    "

sed "1d" $1 > no.header
manifest=$(cat no.header)

for i in ${manifest}
do
      ##### variables ##############################
      project=`echo $i| awk -F ',' '{print $1}'`
      barcode=`echo $i| awk -F ',' '{print $2}'`
      docker_bind_path=`echo $i| awk -F ',' '{print $3}'`
      tumor=`echo $i| awk -F ',' '{print $4}'`
      normal=`echo $i| awk -F ',' '{print $5}'`
      ref=`echo $i| awk -F ',' '{print $6}'`
      workdir=`echo $i| awk -F ',' '{print $7}'`
      outdir=`echo $i| awk -F ',' '{print $8}'`
      svaba_ref=`echo $i| awk -F ',' '{print $9}'`
      DBSNP=`echo $i| awk -F ',' '{print $10}'`
      moseklic=`echo $i| awk -F ',' '{print $11}'`
      AArepo=`echo $i| awk -F ',' '{print $12}'`
      ###############################################

        if [ "${AArepo}" == "" ]; then
            echo "some arguments are missing, check csv file"
            break
        fi

    echo "
    ###########################################################################

                               Installing packages ..

    ###########################################################################
    "

    mkdir -p ${workdir}/neoantigen
    cd ${workdir}/neoantigen
    if  [ ! -e ${workdir}/neoantigen/AmpliconSuite-pipeline ]; then

	    echo "cloning AmpliconSuite-pipeline"
	    git clone https://github.com/jluebeck/AmpliconSuite-pipeline.git
	 else
        echo "AmpliconSuite-pipeline exists"
    fi



    echo "
    ###########################################################################

                               Running AA-suite ..

    ###########################################################################
    "

    ## AmpliconSuite-pipeline v.0.1203.12
    aaresults=`echo ${barcode}_"AA_results"`
    MOSEKPATH=`echo ${MOSEKLM_LICENSE_FILE}`
    REPOPATH=`echo ${AA_DATA_REPO}`
    
    if  [ "${MOSEKPATH}" == "" ]; then

        echo "Designating MOSEK license.."
        export MOSEKLM_LICENSE_FILE=${moseklic} >> ~/.bashrc 
        source ~/.bashrc
     else
        echo "MOSEK path exists"
    fi

    if  [ "${REPOPATH}" == "" ]; then
        echo "Designating AA Data_Repo license.."
        export AA_DATA_REPO=${AArepo}/ >> ~/.bashrc 
        touch ${AArepo}/coverage.stats && chmod a+rw coverage.stats 
        source ~/.bashrc
     else
        echo "AA Data_Repo path exists"
    fi 

    if  [ ! -d ${outdir}/${project}/${barcode}/aa-suite/${aaresults} ]; then
	

     mkdir -p ${outdir}/${project}/${barcode}/aa-suite 
     chmod 775 ${outdir}/${project}/${barcode}/aa-suite

     ${workdir}/neoantigen/AmpliconSuite-pipeline/docker/run_paa_docker.py \
        -o ${outdir}/${project}/${barcode}/aa-suite \
        -s ${barcode} -t 32 \
        --bam ${tumor} \
        --normal_bam ${normal} \
        --ref ${ref} \
        --run_AA \
        --AA_extendmode EXPLORE \
        --AA_runmode FULL \
        --run_as_user
    else
        echo "AA-suite output exists"
    fi



    echo "
    ###########################################################################

                            Running breakpoints_to_bed.py ..

    ###########################################################################
    "

    if  [ ! -s ${outdir}/${project}/${barcode}/preneos/${barcode}_BP.bed ]; then

	    mkdir -p ${outdir}/${project}/${barcode}/preneos
        chmod 775 ${outdir}/${project}/${barcode}/preneos
        
        cd ${workdir}/neoantigen

        if  [ ! -d ${workdir}/neoantigen/ecNAPP ]; then

	        echo "cloning ecNAPP"
	        git clone https://github.com/skadbswn/ecNAPP.git
            chmod 775 -R ${workdir}/neoantigen/ecNAPP/
	
        fi

        echo "collecting intervals for region arguement"
        
        bash ${workdir}/neoantigen/ecNAPP/intervals_for_bed.sh ${outdir}/${project}/${barcode}/aa-suite/${aaresults} ${outdir}/${project}/${barcode}/preneos #output name is intervals_for_bp.txt
        btobregions=`cat ${outdir}/${project}/${barcode}/preneos/intervals_for_bp.txt`

        bash ${workdir}/neoantigen/ecNAPP/input-for-btob.sh ${outdir}/${project}/${barcode}/aa-suite/${aaresults} ${barcode} ${outdir}/${project}/${barcode}/preneos
        

        chmod 777 ${outdir}/${project}/${barcode}/preneos/${barcode}_bp.input.txt

        docker run -it --rm -u $(id -u):$(id -g) \
        -v ${docker_bind_path}:${docker_bind_path} \
        -v ${outdir}/${project}/${barcode}/preneos:/home/results \
        namzoo/pythonforbp:v1.2 \
        python3 /home/breakpoints_to_bed.py -i ${outdir}/${project}/${barcode}/preneos/${barcode}_bp.input.txt \
        -r ${btobregions} \
        --add_chr_tag > ${outdir}/${project}/${barcode}/preneos/${barcode}.nameOFresults

        sed -i -e 's/\r$//' ${outdir}/${project}/${barcode}/preneos/${barcode}.nameOFresults 
        #name=`cat ${outdir}/${project}/${barcode}/preneos/${barcode}.nameOFresults`

        #cat ${outdir}/${project}/${barcode}/preneos/${barcode}.nameOFresults | tr -d " \t\n\r" > ${barcode}.processed
        #mv ${barcode}.processed ${outdir}/${project}/${barcode}/preneos/${barcode}_BP.bed
        for line in $(cat ${outdir}/${project}/${barcode}/preneos/${barcode}.nameOFresults);
            do 
                mv ${outdir}/${project}/${barcode}/preneos/$line ${outdir}/${project}/${barcode}/preneos/${barcode}_BP.bed
            done
            
        echo "Gather only breakpoints for running get_contig.sh"
        bash ${workdir}/neoantigen/ecNAPP/breakpointsplusone.sh ${outdir}/${project}/${barcode}/preneos ${barcode}

        echo "Change file layout for running svaba"
        bash ${workdir}/neoantigen/ecNAPP/sva.sh ${outdir}/${project}/${barcode}/preneos ${barcode}

        rm ${outdir}/${project}/${barcode}/preneos/${barcode}_startPOS.txt ${outdir}/${project}/${barcode}/preneos/${barcode}_endPOS.txt ${outdir}/${project}/${barcode}/preneos/${barcode}_POSmerged

    fi
   


    echo "
    ###########################################################################

                                 Running SVABA ..

    ###########################################################################
    "

    ## SVABA v.1.1.3
    if  [ ! -e ${outdir}/${project}/${barcode}/svaba/${barcode}.svaba.unfiltered.somatic.sv.vcf ]; then
     	
     mkdir -p ${outdir}/${project}/${barcode}/svaba
     chmod 777 ${outdir}/${project}/${barcode}/svaba
     cd ${outdir}/${project}/${barcode}/svaba
     
        if  [ ! -e ${outdir}/${project}/${barcode}/svaba/tumor.bam ]; then
            ln -s ${tumor} ${outdir}/${project}/${barcode}/svaba/tumor.bam
        fi
        
        if  [ ! -e ${outdir}/${project}/${barcode}/svaba/tumor.bam.bai ]; then
             ln -s ${tumor}.bai ${outdir}/${project}/${barcode}/svaba/tumor.bam.bai
        fi

        if  [ ! -e ${outdir}/${project}/${barcode}/svaba/normal.bam ]; then
            ln -s ${normal} ${outdir}/${project}/${barcode}/svaba/normal.bam
        fi
        
        if  [ ! -e ${outdir}/${project}/${barcode}/svaba/normal.bam.bai ]; then
             ln -s ${normal}.bai ${outdir}/${project}/${barcode}/svaba/normal.bam.bai
        fi

     docker run --rm \
        -v ${docker_bind_path}:${docker_bind_path} \
        -v ${outdir}/${project}/${barcode}/svaba:/home/results \
        namzoo/svaba:latest \
        /svaba/bin/svaba run \
        -a ${barcode} \
        -t ${outdir}/${project}/${barcode}/svaba/tumor.bam \
        -n ${outdir}/${project}/${barcode}/svaba/normal.bam \
        -k ${outdir}/${project}/${barcode}/preneos/${barcode}_svaba_regions.bed \
        -p 32 \
        -G ${svaba_ref} \
        -D ${DBSNP} 

     rm ${outdir}/${project}/${barcode}/svaba/tumor.bam
     rm ${outdir}/${project}/${barcode}/svaba/tumor.bam.bai
     rm ${outdir}/${project}/${barcode}/svaba/normal.bam
     rm ${outdir}/${project}/${barcode}/svaba/normal.bam.bai
     else
        echo "SVABA output exists"
    fi



    echo "
    ###########################################################################

                                Running Polysolver ..

    ###########################################################################
    "

    ## POLYSOLVER v.4
    if  [ ! -e ${outdir}/${project}/${barcode}/polysolver/winners.hla.txt ]; then
        
	    mkdir -p ${outdir}/${project}/${barcode}/polysolver
        chmod 775 $outdir/${project}/${barcode}/polysolver

            if [ "$ref" == "GRCh37" -o  "$ref" == "hg19" ]; then
                Polyref="hg19"
            elif [ "$ref" == "GRCh38" -o "$ref" == "hg38" ]; then 
                Polyref="hg38"
            else 
                echo "The reference of POLYSOLVER must be GRCh37, hg19, GRCh38, or hg38"
            fi

        docker run --rm -it \
            -v ${docker_bind_path}:${docker_bind_path} sachet/polysolver:v4 bash /home/polysolver/scripts/shell_call_hla_type \
            ${tumor} \
            Unknown 1 \
            ${Polyref}  STDFQ 0 \
            ${outdir}/${project}/${barcode}/polysolver
    else
        echo "POLYSOLVER output exists"
    fi

        echo "running HLA_ordering.R"
        docker run -it --rm \
            -v ${docker_bind_path}:${docker_bind_path} namzoo/ecnappr:v1.1 \
            Rscript ${workdir}/neoantigen/ecNAPP/HLA_ordering.R \
            -i ${outdir}/${project}/${barcode}/polysolver/winners.hla.txt \
            -o ${outdir}/${project}/${barcode}/preneos/${barcode}.hla.txt

    echo "done"



    echo "
    ###########################################################################

                            running get_contigs.sh ..

    ###########################################################################
    "

        if [ ! -e ${outdir}/${project}/${barcode}/svaba/${barcode}.alignments.txt ]; then

         gunzip ${outdir}/${project}/${barcode}/svaba/${barcode}.alignments.txt.gz

        fi

        sh ${workdir}/neoantigen/ecNAPP/get_contigs.sh \
        -b ${barcode} \
        -p ${outdir}/${project}/${barcode}/svaba \
        -o ${outdir}/${project}/${barcode}/preneos

    echo "done"



    echo "
    ###########################################################################

                        DNA sequences to OpenReadingFrames ..

    ###########################################################################
    "
        
        ${workdir}/neoantigen/ecNAPP/DNA_to_ORF.py \
        -i ${outdir}/${project}/${barcode}/preneos/${barcode}.fasta.txt \
        -o ${outdir}/${project}/${barcode}/preneos/${barcode}.orf.fasta

    echo "done"



    echo "
    ###########################################################################

                            Running netMHCpan ..

    ###########################################################################
    "

    ## netMHCpan v.4.1b 
        mkdir -p ${outdir}/${project}/${barcode}/netMHCpan
        chmod 775 ${outdir}/${project}/${barcode}/netMHCpan
        hlas=`cat ${outdir}/${project}/${barcode}/preneos/${barcode}.hla.txt`
   
        docker run -it --rm \
            -v ${docker_bind_path}:${docker_bind_path} \
            namzoo/ecmhcpan:v1.1 \
            /netMHCpan-4.1/netMHCpan \
            -BA \
            -a $hlas \
            -f ${outdir}/${project}/${barcode}/preneos/${barcode}.orf.fasta  > ${outdir}/${project}/${barcode}/netMHCpan/neoantigens.output.txt 
    
    echo "done"



    echo "
    ###########################################################################

                Find proteins that strongly bind to MHC classI ..

    ###########################################################################
    "

    grep "SB" ${outdir}/${project}/${barcode}/netMHCpan/neoantigens.output.txt > ${outdir}/${project}/${barcode}/netMHCpan/neoantigens.output.strongbind.txt
        
    echo "All process done!!"


done
