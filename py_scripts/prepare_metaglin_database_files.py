import pandas as pd
import argparse
import subprocess
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build MetaBinG2 customized database", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--path1", type=str, help="Full path of MiCoP_database_viruses/fungi_full_info_formatted.txt file", default="")
    parser.add_argument("--path2", type=str, help="Full path of Metalgin original db_info.txt file", default="")
    parser.add_argument("--organism", type=str, help="viruses or fungi", default="viruses")
    parser.add_argument("--organism_files_folder", type=str, help="Full path of organism_files folder", default="")
    parser.add_argument("--outfolder", type=str, help="Full path of output folder", default="")
    args = parser.parse_args()
    
    full_info = pd.read_csv(args.path1, sep='\t', header=0)
    db_info = pd.read_csv(args.path2, sep='\t', header=0)
    db_info.columns = [col.strip() for col in list(db_info.columns)]
    combine_info = full_info[['accession_id']].merge(db_info[['Accesion','Length','TaxID','Lineage','TaxID_Lineage']], left_on='accession_id', right_on='Accesion').reset_index(drop=True).drop(['accession_id'], axis=1)
    combine_info['TaxID'] = combine_info['TaxID'].astype('float').astype('int')
    combine_info['TaxID_Lineage'] = combine_info['TaxID_Lineage'].replace('\..*','',regex=True)
    genome_folder = os.path.dirname(args.path1)+f'/all_MiCoP_database_{args.organism}_genomes'
    
    for index in range(combine_info.shape[0]):
        _ = subprocess.run(f"cat {genome_folder}/{combine_info.loc[index,'Accesion'].replace('.','_')}.fasta >> {args.organism_files_folder}/taxid_{combine_info.loc[index,'TaxID']}_genomic.fna", shell=True)
        
    
    for file in os.listdir(args.organism_files_folder):
        _ = subprocess.run(f"gzip {args.organism_files_folder}/{file}", shell=True)
    
    combine_info.to_csv(args.outfolder+'/db_info.txt', sep='\t', index=None)
    