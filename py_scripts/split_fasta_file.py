from Bio import SeqIO

fasta_sequences = SeqIO.parse(open('MiCoP_database_fungi_refseq.fna'),'fasta')
linelen = 50

for fasta in fasta_sequences:
    filename = fasta.id.replace('.','_')
    with open(f"all_MiCoP_database_fungi_genomes/{filename}.fasta",'w') as outfile:
        outfile.write(f">{fasta.id}")
        outfile.write("\n")
        outfile.write("\n".join([str(fasta.seq)[i:i+linelen] for i in range(0, len(str(fasta.seq)), linelen)]))
        outfile.write("\n")
