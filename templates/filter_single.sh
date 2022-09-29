#!/bin/bash

set -e

echo "Aligning single FASTQ"
echo "${R1}"
ls -lahtr
ls -lahtr index

mkdir output

# Run STAR
STAR \
    --runThreadN ${task.cpus} \
    --genomeDir index \
    --readFilesCommand gunzip -c \
    --readFilesIn "${R1}" \
    --outFileNamePrefix output/ \
    --outReadsUnmapped Fastx

echo Done aligning

ls -lahtr
ls -lahtr output

# Rename the output files
rm "${R1}"
gzip -c output/Unmapped.out.mate1 > "${R1}"
LOG_NAME="\$(echo ${R1} | sed 's/.fastq//' | sed 's/.gz//' | sed 's/.fq//')"
mv output/Log.final.out "\${LOG_NAME}.log"