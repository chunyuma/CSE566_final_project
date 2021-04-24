import pandas as pd

gene2refseq = pd.read_csv('gene2refseq', sep='\t', header=0)
gene2refseq = gene2refseq[['#tax_id','GeneID','start_position_on_the_genomic_accession','end_position_on_the_genomic_accession','orientation']]
viruses_gene_info = pd.read_csv('All_Viruses.gene_info', sep='\t', header=0)
viruses_taxid_list = list(set(viruses_gene_info['#tax_id']))
viruses_info = gene2refseq.loc[gene2refseq['#tax_id'].isin(viruses_taxid_list),:].reset_index(drop=True)
viruses_info.to_csv('all_ncbi_viruses_info.txt', sep='\t', index=None)
