import pandas as pd
import argparse
import subprocess
import random
import requests
import time

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract genome fasta from NCBI", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--path", type=str, help="Full path of the all fungi/viruses full info file", default="~/work/CSE566finalproject/data/viruses_fungi_info/MiCoP_database_viruses_full_info_formatted.txt")
    parser.add_argument("--max_n_species", type=int, help="Number of speceis by random selection", default=200)
    parser.add_argument("--seed", type=int, help="Seed for random sampling", default=10020)
    parser.add_argument("--out_fasta", type=str, help="Full path of output folder storing fasta files", default="")
    parser.add_argument("--out_camisim_input_files", type=str, help="Full path of output folder storing the input files for CAMISIM run", default="")
    args = parser.parse_args()

    output_folder_fasta = args.out_fasta
    output_folder_meta = args.out_camisim_input_files
    
    all_info = pd.read_csv(args.path, sep='\t', header=0)
    all_info = all_info.loc[all_info['genome_size'] > 1000, :].reset_index(drop=True)
    full_species_name = list(set(all_info['tax_name']))
    random.seed(args.seed)
    random.shuffle(full_species_name)
    
    selected_species = full_species_name[:args.max_n_species]
    all_info_selected = all_info.loc[all_info.tax_name.isin(selected_species),:].reset_index(drop=True)
    all_info_selected = all_info_selected.loc[~all_info_selected.tax_id.duplicated(),:].dropna().reset_index(drop=True)
    
    id_to_genome_file = []
    metadata_file = ['genome_ID\tOTU\tNCBI_ID\tnovelty_category\n']
    for index in range(all_info_selected.shape[0]):
        nuid = all_info_selected.loc[index,'accession_id']
        out_filename = all_info_selected.loc[index,'accession_id'] + '_' + str(all_info_selected.loc[index,'tax_id']) + '_genomic.fasta'
        res = requests.get(f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id={nuid}&rettype=fasta")
        if res.status_code == 200:
            with open(output_folder_fasta+'/'+out_filename,'w') as out:
                out.writelines(res.text)
            id_to_genome_file.append(f"genome{index+1}\t{output_folder_fasta+'/'+out_filename}\n")
            metadata_file.append(f"genome{index+1}\t{index+1}\t{str(all_info_selected.loc[index,'tax_id'])}\tKnown_strain\n")
        else:
            print(f"Error: can't extract fasta sequence for {all_info_selected.loc[index,'tax_name']} with accession_id {all_info_selected.loc[index,'accession_d']}")
        # sleep 3 seconds to avoid frequently requesting ncbi server
        time.sleep(3)
    
    out_filename = 'genome_to_id_file.tsv'
    with open(output_folder_meta+'/'+out_filename,'w') as out:
        out.writelines(id_to_genome_file)
    
    out_filename = 'metadata.tsv'
    with open(output_folder_meta+'/'+out_filename,'w') as out:
        out.writelines(metadata_file)