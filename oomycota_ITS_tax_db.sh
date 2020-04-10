#!/usr/bin/env bash


### prepare environment
# create folders for scripts and data
mkdir -p scripts


### download necessary scripts
# custom bash scripts
if test -f ./scripts/fetch_gb.py
then
  echo "scripts found"
else
  git clone https://github.com/jgmv/ncbi_data_analysis.git scripts
fi

# system-wide access to scripts
export PATH="$PATH:scripts"


### fetch data
# retrieve GIs for all oomycota cox2 from GenBank
#   (or search manually and download)
search_ncbi_gi_by_term.py -o oomycota.gi 'Stramenopiles[Organism] AND (internal transcribed spacer OR ITS OR ITS1 OR ITS2) not chromosome not genome'

# fecth GB data
fetch_gb.py oomycota.gi -o oomycota.gb

# extract metadata from GB
get_metadata_from_gb.py oomycota.gb -o oomycota.csv

# extract sequences from GB
get_fasta_from_gb.py -o oomycota.fasta oomycota.gb

# extract taxonomy from GB
sed -n -e '/db_xref="taxon:/,/"/ p' oomycota.gb > .temp1
grep "db_xref" .temp1 > .temp2
sed -i 's/                     \/db_xref="taxon://g' .temp2
sed -i 's/"//g' .temp2
parse_taxids.py .temp2 -o .temp3

grep ">" oomycota.fasta > .temp4
sed -i 's/>//g' .temp4
cut -f1 -d';' --complement .temp3 > .temp5
paste --delimiters=';' .temp4 .temp5 > oomycota.tax

rm -rf .temp*


### end
