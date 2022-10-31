
# Let's look for neoantigens!

created by Harold and Mary of CBM LAB

## Workflow of ecNAPP
![ing](https://user-images.githubusercontent.com/86759935/198952280-ea38ed73-16d7-484f-af9a-475aa0b6af09.png)


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

For the additional info of reference(`DBSNP`), please visit the official svaba github([HERE](https://github.com/walaj/svaba)).

## 3. [POLYSOLVER](https://hub.docker.com/r/sachet/polysolver)

We used docker image for polysolver. Since it has its own reference inside the image, we can choose genome build by argument, `hg19` or `hg38`.

Polysolver gives output with fixed name `winners.hla.txt`, so the output is created under barcode folder.

Don't worry, the input hla will have it's own name while going through the next process.


## 4. [netMHCpan](https://services.healthtech.dtu.dk/service.php?NetMHCpan-4.1)

for the final output of neoantigens, we are using `netMHCpan4.1b` to find peptides binding with MHC class I. 

the final output will be under this header:

| Pos |     MHC     |  Peptide  |    Core   | Of | Gp | Gl | Ip | Il |   Icore   | identity |  Score_EL | %Rank_EL | BindLevel |
|:---:|:-----------:|:---------:|:---------:|:--:|:--:|:--:|:--:|:--:|:---------:|:--------:|:---------:|:--------:|:---------:|
|  1  | HLA-B*40:01 | NETQRLLLL | NETQRLLLL |  0 |  0 |  0 |  0 |  0 | NETQRLLLL |  PEPLIST | 0.7000450 |   0.237  |   <= SB   |


- where:
	- Pos: Residue number (starting from 0) of the peptide in the protein sequence.
	- HLA: Specified MHC molecule / Allele name.
	- Peptide: Amino acid sequence of the potential ligand.
	- Core: The minimal 9 amino acid binding core directly in contact with the MHC.
	- Of: The starting position of the Core within the Peptide (if > 0, the method predicts a N-terminal protrusion).
	- Gp: Position of the deletion, if any.
	- Gl: Length of the deletion, if any.
	- Ip: Position of the insertion, if any.
	- Il: Length of the insertion, if any.
	- Icore: Interaction core. This is the sequence of the binding core including eventual insertions of deletions.
	- Identity: Protein identifier, i.e. the name of the FASTA entry.
	- Score: The raw prediction score.
	- %Rank: Rank of the predicted binding score compared to a set of random natural peptides. This measure is not affected by inherent bias of certain molecules towards higher or lower mean predicted affinities. Strong binders are defined as having %rank<0.5, and weak binders with %rank<2. We advise to select candidate binders based on %Rank rather than Score
	- BindLevel: (SB: Strong Binder, WB: Weak Binder). The peptide will be identified as a strong binder if the %Rank is below the specified threshold for the strong binders (by default, 0.5%). The peptide will be identified as a weak binder if the %Rank is above the threshold of the strong binders but below the specified threshold for the weak binders (by default, 2%).
