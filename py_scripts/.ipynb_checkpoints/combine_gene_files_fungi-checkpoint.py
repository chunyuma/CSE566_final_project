import pandas as pd

gene2refseq = pd.read_csv('gene2refseq', sep='\t', header=0)
gene2refseq = gene2refseq[['#tax_id','GeneID','start_position_on_the_genomic_accession','end_position_on_the_genomic_accession','orientation']]
fungi_gene_info = pd.read_csv('All_Fungi.gene_info', sep='\t', header=0)
fungi_taxid_list = list(set(fungi_gene_info['#tax_id']))
fungi_info = gene2refseq.loc[gene2refseq['#tax_id'].isin(fungi_taxid_list),:].reset_index(drop=True)
fungi_info.to_csv('all_ncbi_fungi_info.txt', sep='\t', index=None)
