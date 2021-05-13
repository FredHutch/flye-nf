#!/usr/bin/env nextflow

// Function which prints help message text
def helpMessage() {
    log.info"""
    Usage:

    nextflow run FredHutch/flye-nf <ARGUMENTS>
    
    Required Arguments:
      --manifest            File containing the location of all input genomes and reads to process
      --output_folder       Folder to place analysis outputs

    Optional Arguments (passed directly to flye):
      --read-type           Type of PacBio or MinION reads passed in to Flye, either raw, corrected, or HiFi (PacBio-only)
                            Default: pacbio-raw
                            Options: pacbio-raw, pacbio-corr, pacbio-hifi, nano-raw, nano-corr, subassemblies
      --iterations          Number of polishing iterations
                            Default: 1
      --asm-coverage        Reduced coverage for initial disjointig assembly
                            Default: not set
    
    For more details on Flye, see https://github.com/fenderglass/Flye/blob/flye/docs/USAGE.md

    Manifest:

        The manifest is a comma-separated table (CSV) with two columns, name and reads. For example,

        name,reads
        genomeA,pacbio_reads/genomeA.fastq.gz
        genomeB,pacbio_reads/genomeB.fastq.gz

    """.stripIndent()
}

// Show help message if the user specifies the --help flag at runtime
params.help = false
if (params.help || params.manifest == null || params.output_folder == null){
    // Invoke the function above which prints the help message
    helpMessage()
    // Exit out and do not run anything else
    exit 1
}

// Default options listed here
params.read_type = "pacbio-raw"
params.iterations = 1
params.asm_coverage = 'none'

// Make sure the manifest file exists
if ( file(params.manifest).isEmpty() ){
    log.info"""
    Could not find any file named ${params.manifest}
    """.stripIndent()
}

// Parse the input FASTA files
Channel.from(
    file(
        params.manifest
    ).splitCsv(
        header: true, 
        sep: ","
    )
).ifEmpty { 
    error "Could not find any lines in ${params.manifest}" 
}.filter {
    r -> (r.name != null)
}.ifEmpty { 
    error "Could not find the 'name' header in ${params.manifest}" 
}.filter {
    r -> (r.reads != null)
}.ifEmpty { 
    error "Could not find the 'reads' header in ${params.manifest}" 
}.filter {
    r -> (!file(r.reads).isEmpty())
}.ifEmpty { 
    error "Could not find the files under the 'reads' header in ${params.manifest}" 
}.map {
    r -> [r["name"], file(r["reads"])]
}.set {
    input_ch
}

// Run Flye
process flye {

  // Docker container to use
  container "quay.io/biocontainers/flye:2.8--py37h8270d21_0"
  label "mem_medium"
  errorStrategy 'retry'
  maxRetries 3

  // The `publishDir` tag points to a folder in the host system where all of the output files from this folder will be placed
  publishDir "${params.output_folder}" 
  
  input:
    tuple val(name), file(reads) from input_ch

  // The block below points to the files inside the process working directory which will be retained as outputs (and published to the destination above)
  output:
  file "${name}/*"

"""
#!/bin/bash

set -e

df -h
echo ""
ls -lahtr
echo ""
echo "STARTING FLYE"
echo ""

if [[ "${params.asm_coverage}" == "none" ]]; then

    flye \
        --${params.read_type} ${reads} \
        --out-dir ${name} \
        --threads ${task.cpus} \
        --iterations ${params.iterations} \
        --plasmids

else

    flye \
        --${params.read_type} ${reads} \
        --out-dir ${name} \
        --threads ${task.cpus} \
        --iterations ${params.iterations} \
        --plasmids \
        --asm-coverage ${params.asm_coverage}

fi

"""

}
