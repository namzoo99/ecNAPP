# ecNAPP
# Let's look for neoantigens!

created by Harold and Mary of CBM LAB

## For the use of this script, please prepare
1) Docker
2) mosek license and reference data for AA-suite, svaba
3) csv file consisted of:
| colnames         | definition                                      |
|------------------|-------------------------------------------------|
| project          | project name                                    |
| barcode          | sample barcode                                  |
| docker_bind_path | path where docker will bind to (docker -v)      |
| input            | input file directory                            |
| ref              | reference genome build                          |
| workdir          | working directory where the pipeline will be at |
| outdir           | output directory                                |
| svaba_ref        | directory of reference for svaba (genome)       |
| DBSNP            | directory of reference for svaba (dbsnp)        |
| moseklic         | directory of MOSEK license                      |
| AArepo           | directory of AA repo                            |
	

the `docker_bind_path` must be the parent folder of `input`, `workdir`, `outdir`, `svaba_ref`, and `DBSNP`. Check our [example.csv](https://github.com/skadbswn/ecNAPP/blob/main/example.csv) for more info.

## 1. [AmpliconSuite-pipeline](https://github.com/jluebeck/AmpliconSuite-pipeline)

The arguments are absed on the `HL-NF:AmpliconArchitect`, which are ``` --AA_extendmode EXPLORE --AA_runmode FULL ```. 
To download MOSEK liscence(mosek.lic), visit [HERE](https://www.mosek.com/products/academic-licenses/).

For AA_DATA_REPO, visit [HERE](https://datasets.genepattern.org/?prefix=data/module_support_files/AmpliconArchitect/). 

Genome build should be downloaded with `_indexed` files.



## 2. [SVABA](https://github.com/walaj/svaba)

We used docker image for our pipeline. Since `SVABA` does not have output argument, the `BAM` files need to be placed where the output should be placed using symlink.

After the run, script automatically removes the symlink.

## 3. [POLYSOLVER](https://hub.docker.com/r/sachet/polysolver)

We also used docker image for polysolver. Since it has its own reference inside the image, we can choose genome build by argument, `hg19` or `hg38`.

Polysolver gives output with fixed name `winners.hla.txt`, so the output is created under barcode folder.

Don't worry, the input hla will have it's own name while going through the next process.
