#!/bin/bash

# # requires bbmap: https://sourceforge.net/projects/bbmap/
## set working folder
working_folder=~/work/CSE566finalproject
organism='fungi'

trainingFiles="training_files.txt"
numThreads=8
cmashBaseName="cmash_db_n1000_k60"
cmashDatabase="${cmashBaseName}.h5"
cmashDump="${cmashBaseName}_dump.fa"
prefilterName="${cmashBaseName}_30-60-10.bf"

# copy some of the training data over
# if [ ! -d ${working_folder}/github_repos/profilers/Metalign/data ]; then
# 	mkdir ${working_folder}/github_repos/profilers/Metalign/data
# fi
# if [ ! -d ${working_folder}/github_repos/profilers/Metalign/data/${organism} ]; then
#     mkdir ${working_folder}/github_repos/profilers/Metalign/data/${organism}
# fi
# if [ ! -d ${working_folder}/github_repos/profilers/Metalign/data/${organism}/organism_files ]; then
#     mkdir ${working_folder}/github_repos/profilers/Metalign/data/${organism}/organism_files
# fi

# python ${working_folder}/py_scripts/prepare_metaglin_database_files.py --path1 ${working_folder}/data/viruses_fungi_info/MiCoP_database_${organism}_full_info_formatted.txt --path2 ${working_folder}/github_repos/profilers/Metalign/metaglin_data/db_info.txt --organism fungi --organism_files_folder ${working_folder}/github_repos/profilers/Metalign/data/${organism}/organism_files --outfolder ${working_folder}/github_repos/profilers/Metalign/data/${organism}

# # store the names of the training files
# rm $trainingFiles 2> /dev/null
# find ${working_folder}/github_repos/profilers/Metalign/data/${organism}/organism_files/ -type f -name "*.fna.gz" > ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${trainingFiles}

# re-train CMash
echo "re-training CMash"
rm ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${cmashDatabase} 2> /dev/null
python ${working_folder}/github_repos/others/CMash/scripts/MakeStreamingDNADatabase.py ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${trainingFiles} ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${cmashDatabase} -n 1000 -k 60 #-v

# make streaming pre-filter
echo "making streaming pre-filter"
rm ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${prefilterName} 2> /dev/null
python ${working_folder}/github_repos/others/CMash/scripts/MakeStreamingPrefilter.py ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${cmashDatabase} ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${prefilterName} 30-60-10

# dump all the k-mers in the new training database
echo "dumping training k-mers"
rm ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${cmashDump} 2> /dev/null
python ${working_folder}/github_repos/others/CMash/scripts/dump_kmers.py ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${cmashDatabase} ${working_folder}/github_repos/profilers/Metalign/data/${organism}/${cmashDump}

# do the kmc counting of the k-mers
echo "running kmc"
cd ${working_folder}/github_repos/profilers/Metalign/data/${organism}/
rm ${cmashBaseName}_dump.kmc_pre 2> /dev/null
rm ${cmashBaseName}_dump.kmc_suf 2> /dev/null
# count all the k-mers in the training database, -ci0 means include them all, -cs3 use small counters
kmc -v -k60 -fa -ci0 -cs3 -t${numThreads} -jlogsample ${cmashDump} ${cmashBaseName}_dump ${working_folder}/github_repos/profilers/Metalign/data/${organism}/