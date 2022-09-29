#!/bin/bash

set -e

echo "Building reference for $ref"
ls -lahtr

mkdir index

# Run STAR
STAR \
    --runThreadN ${task.cpus} \
    --runMode genomeGenerate \
    --genomeDir index \
    --genomeFastaFiles "${ref}"

echo Done