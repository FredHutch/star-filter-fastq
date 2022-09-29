#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// All of the default parameters are being set in `nextflow.config`

// Index the reference sequence
process index {
    // Docker/Singularity container used to run the process
    container "${params.container__star}"

    // Resources to use
    cpus "${params.cpus}"
    memory "${params.memory_gb}.GB"
    
    input:
    // Reference Genome FASTA
    path ref

    output:
    // Capture all output files in the index/ folder
    path "index/*"

    script:
    template "index.sh"
}

// Process to filter paired-end FASTQ data
process filter_paired {
    container "${params.container__star}"
    publishDir "${params.outdir}", mode: "copy", overwrite: true, pattern: "${R1}"
    publishDir "${params.outdir}", mode: "copy", overwrite: true, pattern: "${R2}"
    publishDir "${params.outdir}/logs", mode: "copy", overwrite: true, pattern: "*.log"
    cpus "${params.cpus}"
    memory "${params.memory_gb}.GB"
    
    input:
    // Pair of FASTQ files
    tuple path(R1), path(R2)
    // Reference Database Files
    path "index/"

    output:
    path "${R1}"
    path "${R2}"
    path "*.log"

    script:
    template "filter_paired.sh"
}

// Process to filter single-end FASTQ data
process filter_single {
    container "${params.container__star}"
    publishDir "${params.outdir}", mode: "copy", overwrite: true, pattern: "${R1}"
    publishDir "${params.outdir}/logs", mode: "copy", overwrite: true, pattern: "*.log"
    cpus "${params.cpus}"
    memory "${params.memory_gb}.GB"
    
    input:
    // FASTQ file
    path R1
    // Reference Database Files
    path "index/"

    output:
    path "${R1}"
    path "*.log"

    script:
    template "filter_single.sh"
}

// Main workflow
workflow {

    // The user must specify an output directory
    if ( "${params.outdir}" == "false" ){
        error "Must specify parameter 'outdir'"
    }

    // The user must specify a reference sequence
    if ( "${params.reference}" == "false" ){
        error "Must specify parameter 'reference'"
    }

    log.info"""
    FredHutch/star-filter-fastq

    Parameters:

        // User file input
        reference = "${params.reference}"
        paired_samplesheet = "${params.paired_samplesheet}"
        paired_path = "${params.paired_path}"
        single_samplesheet = "${params.single_samplesheet}"
        single_path = "${params.single_path}"
        outdir = "${params.outdir}"

        // Resource allocation
        cpus = "${params.cpus}"
        memory_gb = "${params.memory_gb}"

        // Containers used for execution
        container__star = "${params.container__star}"
    """.stripIndent()

    // Make sure that the path is valid
    ref = file("${params.reference}", checkIfExists: true, glob: false)

    // Index the reference
    index(ref)

    // If the user specified paired-end FASTQ data
    if ( params.paired_samplesheet || params.paired_path ){

        // Make an empty channel
        Channel
            .empty()
            .set { paired_fastq }

        if ( params.paired_samplesheet ){
            Channel
                .fromPath(
                    "${params.paired_samplesheet}",
                    checkIfExists: true,
                    glob: false
                )
                .splitCsv(
                    header: true
                )
                .map {
                    row -> [
                        file(row.fastq_1, checkIfExists: true),
                        file(row.fastq_2, checkIfExists: true)
                    ]
                }
                .set { paired_samplesheet_ch}
        } else {
            Channel.empty().set { paired_samplesheet_ch }
        }

        if ( params.paired_path ){
            Channel
                .fromFilePairs(
                    "${params.paired_path}",
                    checkIfExists: true,
                    glob: true
                )
                .map {
                    row -> [row[1][0], row[1][1]]
                }
                .set { paired_path_ch}
        } else {
            Channel.empty().set { paired_path_ch }
        }

        // Filter the paired-end FASTQ files provided
        filter_paired(
            paired_samplesheet_ch.mix(paired_path_ch),
            index.out
        )
    }

    // If the user specified single-end FASTQ data
    if ( params.single_samplesheet || params.single_path ){

        // Make an empty channel
        Channel
            .empty()
            .set { single_fastq }

        if ( params.single_samplesheet ){
            Channel
                .fromPath(
                    "${params.single_samplesheet}",
                    checkIfExists: true,
                    glob: false
                )
                .splitCsv(
                    header: true
                )
                .map {
                    row -> file(row.fastq_1, checkIfExists: true)
                }
                .set { single_samplesheet_ch}
        } else {
            Channel.empty().set { single_samplesheet_ch }
        }

        if ( params.single_path ){
            Channel
                .fromPath(
                    "${params.single_path}",
                    checkIfExists: true,
                    glob: true
                )
                .set { single_path_ch}
        } else {
            Channel.empty().set { single_path_ch }
        }

        // Filter the single-end FASTQ files provided
        filter_single(
            single_samplesheet_ch.mix(single_path_ch),
            index.out
        )
    }

}