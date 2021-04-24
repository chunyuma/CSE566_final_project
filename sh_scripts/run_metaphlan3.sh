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
            metaphlan ${fq_file1} --input_type fastq --add_viruses --CAMI_format_output --unknown_estimation --nproc 8 --output_file pwd/profiled_metagenome$5.txt
        else
            metaphlan ${fq_file1} --input_type fastq --add_viruses --CAMI_format_output --unknown_estimation --nproc 8 --output_file $4/profiled_metagenome$5.txt
        fi
    elif [[ "$3" == "fungi" ]]; then
        if [[ "$4" == "None" ]]; then
            metaphlan ${fq_file1} --input_type fastq --CAMI_format_output --unknown_estimation --nproc 8 --output_file pwd/profiled_metagenome$5.txt
        else
            metaphlan ${fq_file1} --input_type fastq --CAMI_format_output --unknown_estimation --nproc 8 --output_file $4/profiled_metagenome$5.txt
        fi
    else
        echo "MiCoP only supports '--virus' or '--fungi'"
    fi
else
    fq_file2=$2
    if [[ "$3" == "virus" ]]; then
        if [[ "$4" == "None" ]]; then
            metaphlan ${fq_file1},${fq_file2} --input_type fastq --bowtie2out metagenome.bowtie2.bz2 --add_viruses --CAMI_format_output --unknown_estimation --nproc 8 --output_file pwd/profiled_metagenome$5.txt
        else
            metaphlan ${fq_file1},${fq_file2} --input_type fastq --bowtie2out metagenome.bowtie2.bz2 --add_viruses --CAMI_format_output --unknown_estimation --nproc 8 --output_file $4/profiled_metagenome$5.txt
        fi
    elif [[ "$3" == "fungi" ]]; then
        if [[ "$4" == "None" ]]; then
            metaphlan ${fq_file1},${fq_file2} --input_type fastq --bowtie2out metagenome.bowtie2.bz2 --CAMI_format_output --unknown_estimation --nproc 8 --output_file pwd/profiled_metagenome$5.txt
        else
            metaphlan ${fq_file1},${fq_file2} --input_type fastq --bowtie2out metagenome.bowtie2.bz2 --CAMI_format_output --unknown_estimation --nproc 8 --output_file $4/profiled_metagenome$5.txt
        fi
    else
        echo "MiCoP only supports '--virus' or '--fungi'"
    fi
fi
