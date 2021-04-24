#!/bin/bash

if [[ "$1" == "None" ]]; then
    echo "No argument supplied"
    exit 0
else
    fq_file1=$1
fi

if [[ "$2" == "None" ]]; then
    if [[ "$3" == "virus" ]]; then
        if [[ "$4" == "None" ]]; then
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} --virus --paired --output pwd/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py pwd/alignments$5.sam --virus --read_cutoff 1 --output pwd/abundances$5.txt
        else
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} --virus --paired --output $4/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py $4/alignments$5.sam --virus --read_cutoff 1 --output $4/abundances$5.txt
        fi
    elif [[ "$3" == "fungi" ]]; then
        if [[ "$4" == "None" ]]; then
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} --fungi --paired --output pwd/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py pwd/alignments$5.sam --fungi --read_cutoff 1 --output pwd/abundances$5.txt
        else
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} --fungi --paired --output $4/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py $4/alignments$5.sam --fungi --read_cutoff 1 --output $4/abundances$5.txt
        fi
    else
        echo "MiCoP only supports '--virus' or '--fungi'"
    fi
else
    fq_file2=$2
    if [[ "$3" == "virus" ]]; then
        if [[ "$4" == "None" ]]; then
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} ${fq_file2} --virus --output pwd/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py pwd/alignments$5.sam --virus --read_cutoff 1 --output pwd/abundances$5.txt
        else
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} ${fq_file2} --virus --output $4/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py $4/alignments$5.sam --virus --read_cutoff 1 --output $4/abundances$5.txt
        fi
    elif [[ "$3" == "fungi" ]]; then
        if [[ "$4" == "None" ]]; then
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} ${fq_file2} --fungi --output pwd/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py pwd/alignments$5.sam --fungi --read_cutoff 1 --output pwd/abundances$5.txt
        else
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/run-bwa.py ${fq_file1} ${fq_file2} --fungi --output $4/alignments$5.sam
            python ~/work/CSE566finalproject/github_repos/profilers/MiCoP/compute-abundances.py $4/alignments$5.sam --fungi --read_cutoff 1 --output $4/abundances$5.txt
        fi
    else
        echo "MiCoP only supports '--virus' or '--fungi'"
    fi
fi
