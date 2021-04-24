#!/bin/bash
#### This script is the main script for this profiler comparison project ####

## set working folder
working_folder=~/work/CSE566finalproject

## step0 Download new taxonomy dump file from NCBI
echo "step0 Download new taxonomy dump file from NCBI"
if [ ! -d ${working_folder}/data ]; then
	mkdir ${working_folder}/data
fi
cd ${working_folder}/data
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz
mv new_taxdump.tar.gz ncbi-new_taxonomy_20210411.tar.gz
if [ ! -d ${working_folder}/data/temp ]; then
	mkdir ${working_folder}/data/temp
    cd ${working_folder}/data/temp
    ln -s ../ncbi-new_taxonomy_20210411.tar.gz
    tar zxvf ncbi-new_taxonomy_20210411.tar.gz
fi
cd ${working_folder}/data/viruses_fungi_info
ln -s ${working_folder}/data/temp/rankedlineage.dmp

# # step1 Generate simulated data
echo "step1 Generate simulated data"
if [ ! -d ${working_folder}/data/simulated_data ]; then
	mkdir ${working_folder}/data/simulated_data
fi
cd ${working_folder}/data/simulated_data
if [ ! -d ${working_folder}/data/simulated_data/fasta ]; then
	mkdir ${working_folder}/data/simulated_data/fasta
fi
cd ${working_folder}/data/simulated_data/fasta
mkdir fungi viruses
if [ ! -d ${working_folder}/data/simulated_data/camisim_out ]; then
	mkdir ${working_folder}/data/simulated_data/camisim_out
fi
cd ${working_folder}/data/simulated_data/camisim_out
mkdir fungi viruses

cd ${working_folder}

if [ ! -d ${working_folder}/CAMISIM ]; then
	git clone https://github.com/CAMI-challenge/CAMISIM.git
fi
if [ ! -d ${working_folder}/CAMISIM/new_config_settting_run ]; then
	mkdir ${working_folder}/CAMISIM/new_config_settting_run
fi
if [ ! -d ${working_folder}/CAMISIM/new_config_settting_run/virus_run ]; then
	mkdir ${working_folder}/CAMISIM/new_config_settting_run/virus_run
fi
if [ ! -d ${working_folder}/CAMISIM/new_config_settting_run/fungi_run ]; then
	mkdir ${working_folder}/CAMISIM/new_config_settting_run/fungi_run
fi

if [ ! -d ${working_folder}/data/intermediate_files ]; then
	mkdir ${working_folder}/data/intermediate_files
fi

python ${working_folder}/py_scripts/format_rankedlineage_dump.py --path ${working_folder}/data/temp/rankedlineage.dmp --outfolder ${working_folder}/data/viruses_fungi_info/

python ${working_folder}/py_scripts/extract_genes_fasta.py --path ${working_folder}/data/viruses_fungi_info/MiCoP_database_viruses_full_info_formatted.txt --all_info ${working_folder}/data/viruses_fungi_info/all_ncbi_viruses_gene_info.txt --organism viruses --shared_taxid_full_info_out ${working_folder}/data/viruses_fungi_info --out_fasta_folder ${working_folder}/data/viruses_fungi_info

python ${working_folder}/py_scripts/extract_genes_fasta.py --path ${working_folder}/data/viruses_fungi_info/MiCoP_database_fungi_full_info_formatted.txt --all_info ${working_folder}/data/viruses_fungi_info/all_ncbi_fungi_gene_info.txt --organism fungi --shared_taxid_full_info_out ${working_folder}/data/viruses_fungi_info --out_fasta_folder ${working_folder}/data/viruses_fungi_info

# # For viruses simulated data
python ${working_folder}/py_scripts/extract_genomes_fasta.py --path ${working_folder}/data/viruses_fungi_info/MiCoP_database_viruses_full_info_formatted.txt --max_n_species 500 --out_fasta ${working_folder}/data/simulated_data/fasta/viruses --out_camisim_input_files ${working_folder}/CAMISIM/new_config_settting_run/virus_run
count_genomes=`ls ${working_folder}/data/simulated_data/fasta/viruses | wc -l`
cp ${working_folder}/CAMISIM/defaults/mini_config.ini ${working_folder}/CAMISIM/new_config_settting_run/virus_run/
sed -i.bk "s/max_processors=8/max_processors=16/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/dataset_id=RL/dataset_id=virus_simulated_data/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/output_directory=out/output_directory=~\/work\/CSE566finalproject\/data\/simulated_data\/camisim_out\/viruses/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/readsim=/readsim=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/error_profiles=/error_profiles=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/samtools=/samtools=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/size=0.1/size=1/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/ncbi_taxdump=tools\/ncbi-taxonomy_20170222.tar.gz/ncbi_taxdump=~\/work\/CSE566finalproject\/data\/ncbi-new_taxonomy_20210411_fixed.tar.gz/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/strain_simulation_template=/strain_simulation_template=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/metadata=defaults\/metadata.tsv/metadata=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/virus_run\/metadata.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/id_to_genome_file=defaults\/genome_to_id.tsv/id_to_genome_file=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/virus_run\/genome_to_id_file.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/genomes_total=24/genomes_total=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini
sed -i.bk "s/genomes_real=24/genomes_real=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini

python ${working_folder}/CAMISIM/metagenomesimulation.py ${working_folder}/CAMISIM/new_config_settting_run/virus_run/mini_config.ini

# # For fungi simulated data
python ${working_folder}/py_scripts/extract_genomes_fasta.py --path ${working_folder}/data/viruses_fungi_info/MiCoP_database_fungi_full_info_formatted.txt --max_n_species 100 --out_fasta ${working_folder}/data/simulated_data/fasta/fungi --out_camisim_input_files ${working_folder}/CAMISIM/new_config_settting_run/fungi_run
count_genomes=`ls ${working_folder}/data/simulated_data/fasta/fungi | wc -l`
cp ${working_folder}/CAMISIM/defaults/mini_config.ini ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/
sed -i.bk "s/max_processors=8/max_processors=16/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/dataset_id=RL/dataset_id=fungi_simulated_data/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/output_directory=out/output_directory=~\/work\/CSE566finalproject\/data\/simulated_data\/camisim_out\/fungi/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/readsim=/readsim=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/error_profiles=/error_profiles=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/samtools=/samtools=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/size=0.1/size=1/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/ncbi_taxdump=tools\/ncbi-taxonomy_20170222.tar.gz/ncbi_taxdump=~\/work\/CSE566finalproject\/data\/ncbi-new_taxonomy_20210411_fixed.tar.gz/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/strain_simulation_template=/strain_simulation_template=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/metadata=defaults\/metadata.tsv/metadata=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/fungi_run\/metadata.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/id_to_genome_file=defaults\/genome_to_id.tsv/id_to_genome_file=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/fungi_run\/genome_to_id_file.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/genomes_total=24/genomes_total=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini
sed -i.bk "s/genomes_real=24/genomes_real=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini

python ${working_folder}/CAMISIM/metagenomesimulation.py ${working_folder}/CAMISIM/new_config_settting_run/fungi_run/mini_config.ini


##### Run different profilers
if [ ! -d ${working_folder}/data/run_data ]; then
	mkdir ${working_folder}/data/run_data
fi

# ### MiCoP
if [ ! -d ${working_folder}/data/run_data/MiCoP ]; then
	mkdir ${working_folder}/data/run_data/MiCoP
fi
cd ${working_folder}/data/run_data/MiCoP
mkdir simulated_data mock_data and real_data
cd ${working_folder}/data/run_data/MiCoP/simulated_data
mkdir virus fungi

/usr/bin/time -v /bin/bash ${working_folder}/sh_scripts/run_MiCoP.sh ${working_folder}/data/simulated_data/camisim_out/fungi/2021.04.13_12.12.10_sample_0/reads/anonymous_reads.fq None fungi ${working_folder}/data/run_data/MiCoP/simulated_data/fungi 0


# #### Metaglin
if [ ! -d ${working_folder}/data/run_data/Metaglin ]; then
	mkdir ${working_folder}/data/run_data/Metaglin
fi
cd ${working_folder}/data/run_data/Metaglin
mkdir simulated_data mock_data real_data
cd ${working_folder}/data/run_data/MetaPhlAn3/simulated_data
mkdir virus fungi

## build customized database
/usr/bin/time -v /bin/bash ${working_folder}/sh_scripts/rebuild_Metaglin_database.sh 

## run Metaglin to get abundance
/usr/bin/time -v /bin/bash ${working_folder}/sh_scripts/run_Metaglin.sh ${working_folder}/data/simulated_data/camisim_out/viruses/2021.04.13_11.56.31_sample_0/reads/anonymous_reads.fq virus ${working_folder}/data/run_data/Metalign/simulated_data/original_virus 0


# #### MetaBinG2
if [ ! -d ${working_folder}/data/run_data/MetaBinG2 ]; then
	mkdir ${working_folder}/data/run_data/MetaBinG2
fi
cd ${working_folder}/data/run_data/MetaBinG2
mkdir simulated_data mock_data and real_data
cd ${working_folder}/data/run_data/MetaBinG2/simulated_data
mkdir virus fungi

### build customized database
/usr/bin/time -v python ${working_folder}/py_scripts/build_metabinG2_custom_database.py --path ${working_folder}/data/viruses_fungi_info/MiCoP_database_fungi_full_info_formatted.txt --organism fungi --outfolder ${working_folder}
mv ${working_folder}/db ${working_folder}/github_repos/profilers/MetaBinG2/reference_database/db_customized_fungi

### run MetaBinG2 to get abundance 
cd ${working_folder}/github_repos/profilers/MetaBinG2/source/MetaBinG2kit
/usr/bin/time -v ./MetaBinG2 ${working_folder}/data/simulated_data/camisim_out/fungi/2021.04.13_12.12.10_sample_0/reads/anonymous_reads.fa ${working_folder}/github_repos/profilers/MetaBinG2/reference_database/db_customized_fungi 8 fungi.out 
mv fungi.out ${working_folder}/data/run_data/MetaBinG2/simulated_data/fungi/fungi.out

### convert MetaBinG2output to cami format
python ${working_folder}/py_scripts/convert_metabinG2_to_cami_format.py --tax_name_dump ${working_folder}/data/temp/names.dmp --tax_nodes_dump ${working_folder}/data/temp/nodes.dmp --metabing ${working_folder}/data/run_data/MetaBinG2/simulated_data/virus/viruses.out --cami_file_path ${working_folder}/data/run_data/MetaBinG2/simulated_data/virus/viruses_abundance0.tsv --SampleID metabing2_simulated_viruses

# #### MetaPhlAn 3.0
if [ ! -d ${working_folder}/data/run_data/MetaPhlAn3 ]; then
	mkdir ${working_folder}/data/run_data/MetaPhlAn3
fi
cd ${working_folder}/data/run_data/MetaPhlAn3
mkdir simulated_data mock_data and real_data
cd ${working_folder}/data/run_data/MetaPhlAn3/simulated_data
mkdir virus fungi

/usr/bin/time -v /bin/bash ${working_folder}/sh_scripts/run_metaphlan3.sh ${working_folder}/data/simulated_data/camisim_out/fungi/2021.04.13_12.12.10_sample_0/reads/anonymous_reads.fq None fungi ${working_folder}/data/run_data/MetaPhlAn3/simulated_data/fungi 0

# #### diamond+megan
if [ ! -d ${working_folder}/data/run_data/diamond ]; then
	mkdir ${working_folder}/data/run_data/diamond
fi
cd ${working_folder}/data/run_data/diamond
mkdir simulated_data mock_data real_data
cd ${working_folder}/data/run_data/diamond/simulated_data
mkdir virus fungi

### build diamond database using nr
cd ${working_folder}/github_repos/profilers/diamond
/usr/bin/time -v diamond makedb --in nr -d nr -p 8

### run diamond+megan to get abundance 
/usr/bin/time -v /bin/bash ${working_folder}/sh_scripts/run_diamond_megan.sh ${working_folder}/data/simulated_data/camisim_out/viruses/2021.04.13_11.56.31_sample_0/reads/anonymous_reads.fq virus ${working_folder}/data/run_data/diamond/simulated_data/virus 0

### convert diamond+mega output to cami format
python ${working_folder}/py_scripts/convert_diamond_to_cami_format.py --tax_name_dump ${working_folder}/data/temp/names.dmp --tax_nodes_dump ${working_folder}/data/temp/nodes.dmp --megan_class_count ${working_folder}/data/run_data/diamond/simulated_data/virus/class_count0.txt --cami_file_path ${working_folder}/data/run_data/diamond/simulated_data/virus/class_abundace0.tsv --SampleID diamond_mega_simulated_viruses

### run OPAL to evaluate different software results
tsv_input_path=${working_folder}/data/CAMI_OPAL/data/simulated_data/original_database/virus
python ${working_folder}/github_repos/OPAL/opal.py -g ${working_folder}/data/simulated_data/camisim_out/viruses/taxonomic_profile_0.txt -r superkingdom,species -o ${working_folder}/data/CAMI_OPAL/results/simulated_data/original_database/virus -l "MiCoP, Metalign, MetaBinG2, MetaPhlAn3, Diamond+Megan" ${tsv_input_path}/MiCoP_cami_fmt_abundance.tsv ${tsv_input_path}/Metalign_cami_fmt_abundance.tsv ${tsv_input_path}/MetaBinG2_cami_fmt_abundance.tsv ${tsv_input_path}/MetaPhlAn3_cami_fmt_abundance.tsv ${tsv_input_path}/Diamond_Megan_cami_fmt_abundance.tsv

tsv_input_path=${working_folder}/data/CAMI_OPAL/data/simulated_data/original_database/fungi
python ${working_folder}/github_repos/OPAL/opal.py -g ${working_folder}/data/simulated_data/camisim_out/fungi/taxonomic_profile_0.txt -r superkingdom,species -o ${working_folder}/data/CAMI_OPAL/results/simulated_data/original_database/fungi -l "MiCoP, Metalign, MetaBinG2, Diamond+Megan" ${tsv_input_path}/MiCoP_cami_fmt_abundance.tsv ${tsv_input_path}/Metalign_cami_fmt_abundance.tsv ${tsv_input_path}/MetaBinG2_cami_fmt_abundance.tsv ${tsv_input_path}/Diamond_Megan_cami_fmt_abundance.tsv

######## for mock community data
python ${working_folder}/py_scripts/generate_gold_standard_cami_fmt_mock.py --tax_name_dump ${working_folder}/data/temp/names.dmp --tax_nodes_dump ${working_folder}/data/temp/nodes.dmp --taxonomy_path ${working_folder}/data/mock_data/virus/taxonomy.tsv --cami_file_path ${working_folder}/data/mock_data/virus/gold_standard_cami_fmt.profile --SampleID mock_viruses

######## add new unknown genome for testing robustness 
## for virus 
python ${working_folder}/py_scripts/add_genome_fasta.py --path ${working_folder}/data/viruses_fungi_info/unknown_virus_taxon_ids.txt --new_n_species 30 --out_fasta ${working_folder}/data/simulated_data/robustness_test/fasta/viruses --out_camisim_input_files ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run
count_genomes=`ls ${working_folder}/data/simulated_data/robustness_test/fasta/viruses | wc -l`
cp ${working_folder}/CAMISIM/defaults/mini_config.ini ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/
sed -i.bk "s/max_processors=8/max_processors=16/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/dataset_id=RL/dataset_id=virus_simulated_data/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/output_directory=out/output_directory=~\/work\/CSE566finalproject\/data\/simulated_data\/robustness_test\/camisim_out\/viruses/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/readsim=/readsim=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/error_profiles=/error_profiles=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/samtools=/samtools=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/size=0.1/size=1/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/ncbi_taxdump=tools\/ncbi-taxonomy_20170222.tar.gz/ncbi_taxdump=~\/work\/CSE566finalproject\/data\/ncbi-new_taxonomy_20210411_fixed.tar.gz/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/strain_simulation_template=/strain_simulation_template=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/metadata=defaults\/metadata.tsv/metadata=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/robustness_test\/virus_run\/metadata.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/id_to_genome_file=defaults\/genome_to_id.tsv/id_to_genome_file=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/robustness_test\/virus_run\/genome_to_id_file.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/genomes_total=24/genomes_total=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini
sed -i.bk "s/genomes_real=24/genomes_real=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini

python ${working_folder}/CAMISIM/metagenomesimulation.py ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/virus_run/mini_config.ini

## for fungi 
python ${working_folder}/py_scripts/add_genome_fasta.py --path ${working_folder}/data/viruses_fungi_info/unknown_fungi_taxon_ids.txt --new_n_species 30 --out_fasta ${working_folder}/data/simulated_data/robustness_test/fasta/fungi --out_camisim_input_files ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run
count_genomes=`ls ${working_folder}/data/simulated_data/robustness_test/fasta/fungi | wc -l`
cp ${working_folder}/CAMISIM/defaults/mini_config.ini ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/
sed -i.bk "s/max_processors=8/max_processors=16/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/dataset_id=RL/dataset_id=virus_simulated_data/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/output_directory=out/output_directory=~\/work\/CSE566finalproject\/data\/simulated_data\/robustness_test\/camisim_out\/fungi/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/readsim=/readsim=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/error_profiles=/error_profiles=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/samtools=/samtools=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/size=0.1/size=1/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/ncbi_taxdump=tools\/ncbi-taxonomy_20170222.tar.gz/ncbi_taxdump=~\/work\/CSE566finalproject\/data\/ncbi-new_taxonomy_20210411_fixed.tar.gz/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/strain_simulation_template=/strain_simulation_template=CAMISIM\//" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/metadata=defaults\/metadata.tsv/metadata=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/robustness_test\/fungi_run\/metadata.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/id_to_genome_file=defaults\/genome_to_id.tsv/id_to_genome_file=~\/work\/CSE566finalproject\/CAMISIM\/new_config_settting_run\/robustness_test\/fungi_run\/genome_to_id_file.tsv/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/genomes_total=24/genomes_total=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini
sed -i.bk "s/genomes_real=24/genomes_real=${count_genomes}/" ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini

python ${working_folder}/CAMISIM/metagenomesimulation.py ${working_folder}/CAMISIM/new_config_settting_run/robustness_test/fungi_run/mini_config.ini