import pandas as pd
import argparse
import subprocess

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process full info of fungi and virus by combining with the raw rankedlineage.dmp file", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--path", type=str, help="Full path of the raw rankedlineage.dmp file", default="~/work/CSE566finalproject/data/test/rankedlineage.dmp")
    parser.add_argument("--outfolder", type=str, help="Full path of output folder", default="")
    args = parser.parse_args()

    output_folder = args.outfolder
    res = subprocess.run(f"cat {args.path} | sed s'/\t|\t/\t/g' > {output_folder}/rankedlineage_new.dmp", shell=True)
    if res.returncode==0:
        rankedlineage = pd.read_csv(f"{output_folder}/rankedlineage_new.dmp", sep='\t', header=None, names=['tax_id','tax_name','species','genus','family','order','class','phylum','kingdom','superkingdom','invalid_col'])
        rankedlineage = rankedlineage.drop(columns=['invalid_col'])
        rankedlineage = rankedlineage.astype({'tax_id': 'str'})
    else:
        print("Error: something wrong for your input parameters")
    

    all_ncbi_viruses_full_info = pd.read_csv(output_folder+'/MiCoP_database_viruses_full_info.txt', sep='\t', header=0)
    all_ncbi_viruses_full_info = all_ncbi_viruses_full_info[['accession_id','genome_size','taxon_id']]
    all_ncbi_viruses_full_info = all_ncbi_viruses_full_info.merge(rankedlineage, left_on='taxon_id', right_on='tax_id')
    all_ncbi_viruses_full_info = all_ncbi_viruses_full_info.drop(columns=['taxon_id'])
    all_ncbi_viruses_full_info.to_csv(output_folder+'/MiCoP_database_viruses_full_info_formatted.txt', sep='\t', index=None)
    
    all_ncbi_fungi_full_info = pd.read_csv(output_folder+'/MiCoP_database_fungi_full_info.txt', sep='\t', header=0)
    all_ncbi_fungi_full_info = all_ncbi_fungi_full_info[['accession_id','genome_size','taxon_id']]
    all_ncbi_fungi_full_info = all_ncbi_fungi_full_info.merge(rankedlineage, left_on='taxon_id', right_on='tax_id')
    all_ncbi_fungi_full_info = all_ncbi_fungi_full_info.drop(columns=['taxon_id'])
    all_ncbi_fungi_full_info.to_csv(output_folder+'/MiCoP_database_fungi_full_info_formatted.txt', sep='\t', index=None)
    
