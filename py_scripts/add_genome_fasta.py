import pandas as pd
import argparse
import subprocess
import random
import requests
import time
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract genome fasta from NCBI", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--path", type=str, help="Full path of the unknown fungi/viruses full info file", default="~/work/CSE566finalproject/data/viruses_fungi_info/unknown_virus_taxon_ids.txt")
    parser.add_argument("--new_n_species", type=int, help="Number of unknown speceis to add", default=30)
    parser.add_argument("--seed", type=int, help="Seed for random sampling", default=10020)
    parser.add_argument("--out_fasta", type=str, help="Full path of output folder storing fasta files", default="")
    parser.add_argument("--out_camisim_input_files", type=str, help="Full path of output folder storing the input files for CAMISIM run", default="")
    args = parser.parse_args()

    output_folder_fasta = args.out_fasta
    output_folder_meta = args.out_camisim_input_files
    
    unknown_taxon_info = pd.read_csv(args.path, sep='\t', header=0)
    unknown_taxon_info = unknown_taxon_info.sample(frac=1).reset_index(drop=True)
    count = 0
    index = 0 
    while count < args.new_n_species:
        if index < unknown_taxon_info.shape[0]:
            index += 1
        else:
            break
        nuid = unknown_taxon_info.loc[index,'genomic_nucleotide_accession.version']
        res = requests.get(f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id={nuid}&rettype=fasta")
        if res.status_code == 200:
            genome_len = sum([len(line) for line in res.text.split('\n') if len(line) !=0 and not line.startswith('>')])
            if genome_len > 1000:
                count += 1
                out_filename = unknown_taxon_info.loc[index,'genomic_nucleotide_accession.version'] + '_' + str(unknown_taxon_info.loc[index,'#tax_id']) + '_genomic.fasta'
                with open(output_folder_fasta+'/'+out_filename,'w') as out:
                    out.writelines(res.text)
    
    all_genome_fasta_filename = os.listdir(output_folder_fasta)
    metadata_file = ['genome_ID\tOTU\tNCBI_ID\tnovelty_category\n']
    id_to_genome_file = []
    for index, filename in enumerate(all_genome_fasta_filename):
        id_to_genome_file.append(f"genome{index+1}\t{os.path.join(output_folder_fasta,filename)}\n")
        tax_id = filename.split('_')[2]
        metadata_file.append(f"genome{index+1}\t{index+1}\t{tax_id}\tKnown_strain\n")
    
    out_filename = 'genome_to_id_file.tsv'
    with open(output_folder_meta+'/'+out_filename,'w') as out:
        out.writelines(id_to_genome_file)
    
    out_filename = 'metadata.tsv'
    with open(output_folder_meta+'/'+out_filename,'w') as out:
        out.writelines(metadata_file)