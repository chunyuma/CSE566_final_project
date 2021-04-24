# This script is used to convert a bunch of protein sequence to fasta format
import pickle

### parameter ###
linelen = 50
outfile_name = 'protein.fasta'

#################
with open('final_protein_seq.pkl','rb') as infile:
    protein_seqs = pickle.load(infile)
    if type(protein_seqs) is dict:
        protein_seqs = [[key, value] for key, value in protein_seqs.items()]

with open(outfile_name, 'w') as outfile:
    for seq in protein_seqs:
        outfile.write(f">{seq[0]}")
        outfile.write("\n")
        protein_str = seq[1]
        outfile.write("\n".join([protein_str[i:i+linelen] for i in range(0, len(protein_str), linelen)]))
        outfile.write("\n")

