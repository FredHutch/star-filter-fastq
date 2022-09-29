# STAR Filter FASTQ
Filter FASTQ files by alignment (STAR)

## Purpose

This repository contains a Nextflow workflow for filtering FASTQ files
by alignment to a reference nucleotide sequence.
Using the STAR aligner, it will remove any reads which align to the
provided reference sequence.
When providing paired-end reads, reads will be removed if
both of the two reads in the pair align to the reference.

## Specifying Inputs

> Note: All input files are expected to be GZIP compressed FASTQ

Users may specify inputs either by a wildcard glob, or by specifying a
sample sheet CSV. The sample sheet CSV must have the columns `fastq_1`
and optionally `fastq_2` for processing paired-end FASTQs.

When specifying a wildcard glob for paired-end FASTQ files, the pattern
`{1,2}` must be used to indicate which files should be paired.
For example: `path/to/fastq/data/*.R{1,2}.fastq.gz`.

## Parameters

The parameters used to specify user inputs are:

- `reference`: Path to nucleotide sequence used for alignment (FASTA)
- `paired_samplesheet`: Path to sample sheet CSV for paired-end FASTQ inputs with columns `fastq_1` and `fastq_2`
- `paired_path`: Wildcard glob specifying FASTQ file pairs (using `{1,2}` to indicate pairing)
- `single_samplesheet`: Path to sample sheet CSV for single-end FASTQ inputs with a column named `fastq_1`
- `single_path`: Wildcard glob specifying FASTQ files to process
- `outdir`: Folder where output files should be placed
