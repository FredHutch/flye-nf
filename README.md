# Flye-NF
Nextflow workflow running the Flye tool for microbial genome assembly

For details on the Flye assembler, see [the documentation](https://github.com/fenderglass/Flye).

The algorithm and benchmarks are described in the [Nature Biotechnology manuscript](https://doi.org/10.1038/s41587-019-0072-8).
Citation: "Assembly of Long Error-Prone Reads Using Repeat Graphs",
Kolmogorov et al, Nature Biotechnology 37, 540–546 (2019). doi:10.1038/s41587-019-0072-8.

```
Usage:

nextflow run FredHutch/flye-nf <ARGUMENTS>

Required Arguments:
    --manifest            File containing the location of all input genomes and reads to process
    --output_folder       Folder to place analysis outputs

Optional Arguments (passed directly to flye):
    --read-type           Type of PacBio or MinION reads passed in to Flye, either raw, corrected, or HiFi (PacBio-only)
                        Default: pacbio-raw
                        Options: pacbio-raw, pacbio-corr, pacbio-hifi, nano-raw, nano-corr, subassemblies
    --genome-size         Estimated genome size, for example, 5m or 2.6g.
                        Default: 5m
    --iterations          Number of polishing iterations
                        Default: 1

For more details on Flye, see https://github.com/fenderglass/Flye/blob/flye/docs/USAGE.md

Manifest:

    The manifest is a comma-separated table (CSV) with two columns, name and reads. For example,

    name,reads
    genomeA,pacbio_reads/genomeA.fastq.gz
    genomeB,pacbio_reads/genomeB.fastq.gz
```
