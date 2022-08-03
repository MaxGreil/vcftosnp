# vcftosnp

Proof of concept of a DNA-Seq pipeline from reads over VCF to SNP (including quality control) with Nextflow.

## Prerequisites

* Unix-like OS (Linux, macOS, etc.)
* [Java](https://openjdk.java.net) version 8
* [Docker](https://docs.docker.com/engine/install/) engine 1.10.x (or later)

### Necessary files

* Reads to be mapped must be stored in compressed `.fastq.gz` file format in folder `data`

## Additional necessary files

If the reads to be analyzed originate from a human DNA-Seq experiment, this additional file must be stored in folder `data`:

* Assembly of the human genome (GRCh38 Genome Reference Consortium Human Reference 38)

```
hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
```

## Table of Contents

* [Quick start](#Quick-start)
* [Installation](#Installation)
* [Arguments](#Arguments)
* [Documentation](#Documentation)

## Quick start

## Installation

Clone this repository with the following command:

```
git clone https://github.com/maxgreil/vcftosnp && cd vcftosnp
```

Then, install Nextflow by using the following command:

```
curl https://get.nextflow.io | bash
```

The above snippet creates the `nextflow` launcher in the current directory.

Finally pull the following Docker container:

```
docker pull maxgreil/vcftosnp
```

Alternatively, you can build the Docker Image yourself using the following command:

```
cd docker && docker image build . -t maxgreil/vcftosnp
```

## Arguments

### Optional Arguments

| Argument  | Usage                            | Description                                                          |
|-----------|----------------------------------|----------------------------------------------------------------------|
| --reads| \<files\>                           | Directory and glob pattern of input files|
| --outdir  | \<folder\>                       | Directory to save output files                                    |

## Documentation

### Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using the following steps:

