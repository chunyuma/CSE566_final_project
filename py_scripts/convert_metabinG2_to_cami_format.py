import argparse
import re
from Bio import Entrez
Entrez.email = "Your.Name.Here@example.org"


RANKS = {'superkingdom': 0, 'phylum': 1, 'class': 2, 'order': 3, 'family': 4, 'genus': 5, 'species': 6, 'strain': 7}
RANK_LIST = ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']


def parseargs():    # handle user arguments
    parser = argparse.ArgumentParser(description="Convert metabing format profile to CAMI/OPAL format profile.")
    parser.add_argument('--tax_name_dump', required=True, help='Taxonomy name dump file.')
    parser.add_argument('--tax_nodes_dump', required=True, help='Taxonomy nodes dump file.')
    parser.add_argument('--metabing', required=True, help='Input metabinG2 file name (without .stats extesion).')
    parser.add_argument('--cami_file_path', required=True, help='CAMI format output file.')
    parser.add_argument('--id_is_taxid', action="store_true", required=False, help='ID is taxid. Not need to call NCBI API to convert accession id to taxid', default=False)
    parser.add_argument('--SampleID', required=True, help='What to put for SampleID field in CAMI format.')
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


def match_id_to_abundance(metabing_file):
    id_to_abundance = dict()
    with(open(metabing_file, 'r')) as infile:
        for line in infile:
            splits = line.strip().split('\t')
            id_number = splits[-1]
            if id_number in id_to_abundance:
                id_to_abundance[id_number] += 1
            else:
                id_to_abundance[id_number] = 1
        total_count = sum([id_to_abundance[id_number] for id_number in id_to_abundance])
        for id_number in id_to_abundance:
            id_to_abundance[id_number] = id_to_abundance[id_number] / total_count * 100.0
    return id_to_abundance


def translate_id_to_taxid(id_to_abundance):
    taxid_to_abundance = dict()
    for id_number in id_to_abundance:
        try:
            handle = Entrez.elink(dbfrom="nuccore", db='taxonomy', id=id_number)
            record = Entrez.read(handle)
            taxid = record[0]['LinkSetDb'][0]['Link'][0]['Id']
            taxid_to_abundance[taxid] = ['',id_to_abundance[id_number]]
        except:
            if id_number == 'NW_003522875.1': ## 'NW_003522875.1' is obsolete version, need to manually set tax id
                taxid = '861557'
                taxid_to_abundance[taxid] = ['',id_to_abundance[id_number]]
            elif id_number == 'NW_006887829.1': ## 'NW_006887829.1' is obsolete version, need to manually set tax id
                taxid = '1287680'
                taxid_to_abundance[taxid] = ['',id_to_abundance[id_number]]
            elif id_number == '52627071': ## '52627071' is obsolete version, need to manually set tax id
                taxid = '10464'
            elif id_number == '966198969': ## '966198969' is obsolete version, need to manually set tax id
                taxid = '1747326'
            else:
                print(f"Error: Can't find taxon id for accession id number {id_number}", flush=True)
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


def write_cami_file(taxid_to_cami_fields, cami_file, sample_id):
    with(open(cami_file, 'w')) as outfile:
        outfile.write('@SampleID:' + str(sample_id) + '\n')
        outfile.write('@Version:0.9.1\n')
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
    id_to_abundance = match_id_to_abundance(args.metabing)
    if args.id_is_taxid is True:
        taxid_to_abundance = {taxid:['',id_to_abundance[taxid]] for taxid in id_to_abundance}
    else:
        taxid_to_abundance = translate_id_to_taxid(id_to_abundance)
    taxid_to_cami_fields = generate_cami_fields(taxid_to_abundance, taxtree)
    taxid_to_cami_fields = accumulate_abundances(taxid_to_cami_fields)
    write_cami_file(taxid_to_cami_fields, args.cami_file_path, args.SampleID)