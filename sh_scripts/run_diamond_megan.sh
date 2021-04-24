#!/bin/bash

if [[ "$1" == "None" ]]; then
    echo "No argument supplied"
    exit 0
else
    fq_file1=$1
fi

if [[ "$2" == "virus" ]]; then
    if [[ "$3" == "None" ]]; then
        diamond blastx --query ${fq_file1} --db ~/work/CSE566finalproject/github_repos/profilers/diamond/nr --daa pwd/viruses$4.daa --threads 8
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/daa2rma -i pwd/viruses$4.daa -o pwd/viruses$4.rma -mdb ~/work/CSE566finalproject/github_repos/profilers/diamond/megan-map-Jan2021.db
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/rma2info -i pwd/viruses$4.rma -c2c Taxonomy > pwd/class_count$4.txt
    else
        diamond blastx --query ${fq_file1} --db ~/work/CSE566finalproject/github_repos/profilers/diamond/nr --daa $3/viruses$4.daa --threads 8
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/daa2rma -i $3/viruses$4.daa -o $3/viruses$4.rma -mdb ~/work/CSE566finalproject/github_repos/profilers/diamond/megan-map-Jan2021.db
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/rma2info -i $3/viruses$4.rma -c2c Taxonomy > $3/class_count$4.txt
    fi
elif [[ "$2" == "fungi" ]]; then
    if [[ "$3" == "None" ]]; then
        diamond blastx --query ${fq_file1} --db ~/work/CSE566finalproject/github_repos/profilers/diamond/nr --daa pwd/fungi$4.daa --threads 8
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/daa2rma -i pwd/fungi$4.daa -o pwd/fungi$4.rma -mdb ~/work/CSE566finalproject/github_repos/profilers/diamond/megan-map-Jan2021.db
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/rma2info -i pwd/fungi$4.rma -c2c Taxonomy > pwd/class_count$4.txt
    else
        diamond blastx --query ${fq_file1} --db ~/work/CSE566finalproject/github_repos/profilers/diamond/nr --daa $3/fungi$4.daa --threads 8
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/daa2rma -i $3/fungi$4.daa -o $3/fungi$4.rma -mdb ~/work/CSE566finalproject/github_repos/profilers/diamond/megan-map-Jan2021.db
        ~/work/CSE566finalproject/github_repos/profilers/diamond/megan_tools/tools/rma2info -i $3/fungi$4.rma -c2c Taxonomy > $3/class_count$4.txt
    fi
else
    echo "MiCoP only supports '--virus' or '--fungi'"
fi
