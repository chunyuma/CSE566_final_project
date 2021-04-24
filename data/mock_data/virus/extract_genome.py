import pandas as pd
import requests
import time

taxonomy = pd.read_csv('taxonomy.tsv', sep='\t', header=0)
output_folder_fasta = 'genomes_fasta'

for index in range(taxonomy.shape[0]):
    nuid = taxonomy.loc[index,'accession']
    out_filename = taxonomy.loc[index,'accession'] + '_' + str(taxonomy.loc[index,'tax_id']) + '_genomic.fasta'
    res = requests.get(f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id={nuid}&rettype=fasta")
    if res.status_code == 200:
        with open(output_folder_fasta+'/'+out_filename,'w') as out:
            out.writelines(res.text)
    else:
        print(f"Error: can't extract fasta sequence for {taxonomy.loc[index,'name']} with accession_id {taxonomy.loc[index,'accession']}")
    # sleep 3 seconds to avoid frequently requesting ncbi server
    time.sleep(3)