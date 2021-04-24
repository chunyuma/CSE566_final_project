#!/bin/bash

if [[ "$1" == "None" ]]; then
    echo "No argument supplied"
    exit 0
else
    fq_file1=$1
fi

if [[ "$2" == "virus" ]]; then
    if [[ "$3" == "None" ]]; then
#         python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output pwd/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data/viruses
        python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output pwd/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data
    else
#         python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output $3/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data/viruses
        python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output $3/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data
    fi
elif [[ "$2" == "fungi" ]]; then
    if [[ "$3" == "None" ]]; then
#         python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output pwd/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data/fungi
        python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output pwd/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data
    else
#         python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output $3/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data/fungi
        python ~/work/CSE566finalproject/github_repos/profilers/Metalign/scripts/metalign.py --input_type fastq --sensitive --read_cutoff 1 --threads 8 --verbose --output $3/abundances$4.tsv ${fq_file1} ~/work/CSE566finalproject/github_repos/profilers/Metalign/data
    fi
else
    echo "MiCoP only supports '--virus' or '--fungi'"
fi
