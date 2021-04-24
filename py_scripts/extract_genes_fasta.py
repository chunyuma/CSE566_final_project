import pandas as pd
import argparse
import requests
import csv
import time

def reverse_string(string):
    complement_dict = {'A':'T', 'T':'A', 'C':'G', 'G':'C'}

    if len(string) == 0:
        return None
    else:
        rev_string = string[::-1]
        return ''.join([complement_dict[char] for char in rev_string])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract gene fasta from NCBI", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--path", type=str, help="Full path of the all fungi/viruses full info file", default="~/work/CSE566finalproject/data/viruses_fungi_info/MiCoP_database_viruses_full_info_formatted.txt")
    parser.add_argument("--organism", type=str, help="fungi/viruses", default="viruses")
    parser.add_argument("--linelen", type=int, help="length of each line", default=50)
    parser.add_argument("--all_info", type=str, help="Full path of the all ncbi fungi/viruses gene info file", default="")
    parser.add_argument("--shared_taxid_full_info_out", type=str, help="Full path of the shared taxid fungi/viruses info file", default="")
    parser.add_argument("--out_fasta_folder", type=str, help="Full path of output Fasta folder", default="")
    args = parser.parse_args()
    
    micop_database_info = pd.read_csv(args.path, sep='\t', header=0)
    all_ncbi_info = pd.read_csv(args.all_info, sep='\t', header=0)
    shared_accession_id = set(all_ncbi_info['genomic_nucleotide_accession.version']).intersection(set(micop_database_info['accession_id']))
    all_ncbi_info = all_ncbi_info.loc[all_ncbi_info['genomic_nucleotide_accession.version'].isin(shared_accession_id),:].reset_index(drop=True)
    all_ncbi_info = all_ncbi_info.loc[~all_ncbi_info.duplicated(),:].reset_index(drop=True)
    all_ncbi_info.to_csv(args.shared_taxid_full_info_out + f"/shared_{args.organism}_gene_info.txt", sep='\t', index=None)
    micop_database_info = micop_database_info.loc[micop_database_info['accession_id'].isin(shared_accession_id),:].reset_index(drop=True)
    micop_database_info.to_csv(args.shared_taxid_full_info_out + f"/shared_{args.organism}_full_info_formatted.txt", sep='\t', index=None)
    
    
    outfile = open(args.out_fasta_folder+f'/genes_{args.organism}.fasta', 'w+')
    for index in range(all_ncbi_info.shape[0]):
        accession_id = all_ncbi_info.loc[index,'genomic_nucleotide_accession.version']
        start_pos = all_ncbi_info.loc[index,'start_position_on_the_genomic_accession'] + 1
        end_pos = all_ncbi_info.loc[index,'end_position_on_the_genomic_accession'] + 1
        strand = all_ncbi_info.loc[index,'orientation']
        taxid = all_ncbi_info.loc[index,'#tax_id']
        geneid = all_ncbi_info.loc[index,'GeneID']
        filename = accession_id.replace(".","_")
        fasta_sequences = SeqIO.parse(open(f"all_MiCoP_database_virus_genomes/{filename}.fasta"),'fasta')
        if strand == "+":
            readname = f">{accession_id}_{taxid}_GeneID:{geneid}"
            seq = str(fasta.seq)[(start_pos-1):end_pos]
        else:
            readname = f">{accession_id}_{taxid}_GeneID:{geneid}"
            seq = reverse_string(str(fasta.seq)[(start_pos-1):end_pos]
        outfile.write(readname)
        outfile.write("\n")
        seq = "\n".join([seq[i:i+args.linelen] for i in range(0, len(seq), args.linelen)])
        outfile.write(seq)                    
        outfile.write("\n")
