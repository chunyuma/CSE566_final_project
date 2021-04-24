import argparse

RANKS = {'superkingdom': 0, 'phylum': 1, 'class': 2, 'order': 3, 'family': 4, 'genus': 5, 'species': 6, 'strain': 7}
RANK_LIST = ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']


def parseargs():
    parser = argparse.ArgumentParser(description="Convert megan format profile to CAMI/OPAL format profile.")
    parser.add_argument('--tax_name_dump', required=True, help='Taxonomy name dump file.')
    parser.add_argument('--tax_nodes_dump', required=True, help='Taxonomy nodes dump file.')
    parser.add_argument('--megan_class_count', required=True, help='Input megan class count file name.')
    parser.add_argument('--cami_file_path', required=True, help='CAMI format output file.')
    parser.add_argument('--SampleID', required=True, help='SampleID field in CAMI format.')
    args = parser.parse_args()
    return args


def build_taxtree(name_path, nodes_path):
    taxtree = dict()
    with(open(name_path, 'r')) as names:
        for line in names:
            if 'scientific name' not in line:
                continue
            taxid = line.split()[0]
            name = line.split('|')[1].strip()
            taxtree[taxid] = [name]
    with(open(nodes_path, 'r')) as nodes:
        for line in nodes:
            splits = line.split()
            taxtree[splits[0]].extend([splits[4], splits[2]])
    return taxtree


def trace_lineages(taxid, taxtree):
    name_lineage, taxid_lineage = ['' for i in range(8)], ['' for i in range(8)]
    if taxid in taxtree:
        name, rank, parent_tax_id = taxtree[taxid]
    else:
        return ['NONE', 'NONE', 'NONE']
    if rank not in RANKS:  # if strain is 'no rank'
        name_lineage[-1] = name
        taxid_lineage[-1] = taxid
        taxid = parent_tax_id
    # traverse up the tree
    while taxid != '1':
        if taxid in taxtree:
            name, rank, parent_tax_id = taxtree[taxid]
        else:
            return ['NONE', 'NONE', 'NONE']
        if rank in RANKS:
            index = RANKS[rank]
            name_lineage[index] = name
            taxid_lineage[index] = taxid
        taxid = parent_tax_id
    name_lineage, taxid_lineage = '|'.join(name_lineage).strip('|'), '|'.join(taxid_lineage).strip('|')
    rank = RANK_LIST[name_lineage.count('|')]
    return [name_lineage, taxid_lineage, rank]


def read_class_count(megan_file):
    taxid_to_abundance = dict()
    with(open(megan_file, 'r')) as infile:
        for line in infile:
            splits = line.strip().split('\t')
            taxid = splits[0]
            if taxid not in taxid_to_abundance:
                taxid_to_abundance[taxid] = ['', "{:.5f}".format(float(splits[1]))]
            else:
                taxid_to_abundance[taxid][-1] = "{:.5f}".format(float(taxid_to_abundance[taxid][1]) + float(splits[1]))
    return taxid_to_abundance


def generate_cami_fields(taxid_to_abundance, taxtree):
    taxid_to_cami_fields = dict()
    for taxid in taxid_to_abundance:
        rank, abundance = taxid_to_abundance[taxid]
        name_lineage, taxid_lineage, rank = trace_lineages(taxid, taxtree)
        taxid_to_cami_fields[taxid] = [rank, taxid_lineage, name_lineage, abundance]
    return taxid_to_cami_fields


def accumulate_abundances(taxid_to_cami_fields):
    initial_abundaces = {key: taxid_to_cami_fields[key] for key in taxid_to_cami_fields}
    for taxid in initial_abundaces:
        rank, taxid_lineage, name_lineage, abundance = initial_abundaces[taxid]
        num_level = taxid_lineage.count('|')
        for i in range(num_level):
            higher_taxid = taxid_lineage.split('|')[i]
            if higher_taxid in taxid_to_cami_fields:
                higher_abundance = float(taxid_to_cami_fields[higher_taxid][-1])
                taxid_to_cami_fields[higher_taxid][-1] = str(higher_abundance + float(abundance))
            else:
                higher_rank = RANK_LIST[i]
                higher_taxlin = '|'.join(taxid_lineage.split('|')[:i + 1])
                higher_namelin = '|'.join(name_lineage.split('|')[:i + 1])
                taxid_to_cami_fields[higher_taxid] = [higher_rank, higher_taxlin, higher_namelin, abundance]
    return taxid_to_cami_fields


def renormalize(taxid_to_cami_fields):
    for rank in RANK_LIST:
        taxids_for_rank = [i for i in taxid_to_cami_fields if taxid_to_cami_fields[i][0] == rank]
        rank_total_abundance = sum([float(taxid_to_cami_fields[taxid][-1]) for taxid in taxids_for_rank])
        for taxid in taxids_for_rank:
            taxid_to_cami_fields[taxid][-1] = str(float(taxid_to_cami_fields[taxid][-1]) / rank_total_abundance * 100.0)
    return taxid_to_cami_fields


def write_cami_file(taxid_to_cami_fields, cami_file, sample_id):
    with(open(cami_file, 'w')) as outfile:
        outfile.write('@SampleID:' + str(sample_id) + '\n')
        outfile.write('@Version:Diamond+Megan\n')
        outfile.write('@Ranks: superkingdom|phylum|class|order|family|genus|species|strain\n\n')
        outfile.write('@@TAXID\tRANK\tTAXPATH\tTAXPATHSN\tPERCENTAGE\t_CAMI_genomeID\t_CAMI_OTU\n')
        for i in range(len(RANK_LIST)):
            for taxid in taxid_to_cami_fields:
                if taxid == '':
                    continue
                rank = taxid_to_cami_fields[taxid][0]
                if rank == RANK_LIST[i]:
                    taxid_to_cami_fields[taxid][-1] = "{:.5f}".format(float(taxid_to_cami_fields[taxid][-1]))
                    outfile.write(taxid + '\t' + '\t'.join(taxid_to_cami_fields[taxid]) + '\n')


if __name__ == '__main__':
    args = parseargs()
    taxtree = build_taxtree(args.tax_name_dump, args.tax_nodes_dump)
    taxid_to_abundance = read_class_count(args.megan_class_count)
    if '1' in taxid_to_abundance:
        del taxid_to_abundance['1']
    if '131567' in taxid_to_abundance:
        del taxid_to_abundance['131567']  # also remove "cellular organisms" for the same reason
    taxid_to_cami_fields = generate_cami_fields(taxid_to_abundance, taxtree)
    taxid_to_cami_fields = accumulate_abundances(taxid_to_cami_fields)
    taxid_to_cami_fields = renormalize(taxid_to_cami_fields)
    write_cami_file(taxid_to_cami_fields, args.cami_file_path, args.SampleID)