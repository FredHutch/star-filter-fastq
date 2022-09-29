#!/bin/bash

set -e

echo "Aligning paired FASTQ"
echo "${R1}"
echo "${R2}"
ls -lahtr
ls -lahtr index

mkdir output

# Run STAR
STAR \
    --runThreadN ${task.cpus} \
    --genomeDir index \
    --readFilesCommand gunzip -c \
    --readFilesIn "${R1}" "${R2}" \
    --outFileNamePrefix output/ \
    --outReadsUnmapped Fastx

echo Done aligning

ls -lahtr
ls -lahtr output

# Rename the output files
rm "${R1}" "${R2}"
gzip -c output/Unmapped.out.mate1 > "${R1}"
gzip -c output/Unmapped.out.mate2 > "${R2}"
mv output/Log.final.out "${R1}.log"