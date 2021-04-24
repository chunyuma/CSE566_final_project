import argparse
import subprocess
import csv

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build MetaBinG2 customized database", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--path", type=str, help="Full path of MiCoP_database_viruses/fungi_full_info_formatted.txt file", default="")
    parser.add_argument("--organism", type=str, help="viruses of fungi", default="")
    parser.add_argument("--outfolder", type=str, help="Full path of output folder", default="")
    args = parser.parse_args()

    full_info_file = open(args.path,'r')
    full_info_csv = csv.reader(full_info_file, delimiter="\t")
    for row in full_info_csv:
        break
    column_names = row
    accession_id_index = column_names.index('accession_id')
    species_index = column_names.index('species')
    genus_index = column_names.index('genus')
    family_index = column_names.index('family')
    order_index = column_names.index('order')
    class_index = column_names.index('class')
    phylum_index = column_names.index('phylum')
    
    
    for row in full_info_csv:
        species_name = row[species_index] if len(row[species_index])!=0 else 'None'
        genus_name = row[species_index] if len(row[species_index])!=0 else 'None'
        family_name = row[family_index] if len(row[family_index])!=0 else 'None'
        order_name = row[order_index] if len(row[order_index])!=0 else 'None'
        class_name = row[class_index] if len(row[class_index])!=0 else 'None'
        phylum_name = row[phylum_index] if len(row[phylum_index])!=0 else 'None'

        res = subprocess.run(f"perl ~/work/CSE566finalproject/github_repos/profilers/MetaBinG2/source/MetaBinG2kit/addref.pl ~/work/CSE566finalproject/data/viruses_fungi_info/all_MiCoP_database_{args.organism}_genomes/{row[accession_id_index].replace('.','_')}.fasta {row[accession_id_index]} '{species_name}' '{genus_name}' '{family_name}' '{order_name}' '{class_name}' '{phylum_name}' {args.outfolder}/db", shell=True)
        
    full_info_file.close()
