#!/bin/bash

# load bgzip and tabix utilities
source ~/.bashrc
conda activate chipdip

set -euo pipefail

##################################################
# GENCODE Mouse M25 primary annotation
##################################################

# "It contains the comprehensive gene annotation on the primary assembly
#  (chromosomes and scaffolds) sequence regions"

if [ ! -f "gencode.vM25.primary_assembly.sorted.gtf.gz" ]; then
    wget -q -O - 'https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.primary_assembly.annotation.gtf.gz' |
    gunzip -c |
    awk -F'\t' '!/^#/' |
    sort -k 1,1V -k 4,4n -k 5,5n |
    bgzip > gencode.vM25.primary_assembly.sorted.gtf.gz
    chmod a=r gencode.vM25.primary_assembly.sorted.gtf.gz

    tabix gencode.vM25.primary_assembly.sorted.gtf.gz
    chmod a=r gencode.vM25.primary_assembly.sorted.gtf.gz.tbi
fi

# Extract a transcripts feature type-only GTF file
if [ ! -f "gencode.vM25.primary_assembly.transcripts.gtf.gz" ]; then
    unpigz -c gencode.vM25.primary_assembly.sorted.gtf.gz |
    awk -F'\t' '$3 == "transcript"' |
    sed -E -e 's/gene_type "[^"]+";\s*//' \
           -e 's/transcript_type "[^"]+";\s*//' \
           -e 's/; level [0-9]+;/;/' \
           -e 's/; transcript_support_level "([0-9]+|NA)";/;/' \
           -e 's/tag "[^"]+";\s*//g' \
           -e 's/havana_gene "[^"]+";\s*//' \
           -e 's/havana_transcript "[^"]+";\s*//' |
    bgzip -c > gencode.vM25.primary_assembly.transcripts.gtf.gz
    chmod a=r gencode.vM25.primary_assembly.transcripts.gtf.gz
fi
