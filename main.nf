#!/usr/bin/env nextflow

/*
 * enables modules
 */
nextflow.enable.dsl=2

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */
 
// https://www.ncbi.nlm.nih.gov/sra/?term=ERR4059485
params.reads = "$baseDir/data/*.fastq.gz" //default: "$baseDir/data/*.fastq.gz" + params.singleEnd = true, alternative: "$baseDir/data/*_{1,2}*.fastq.gz" + params.singleEnd = false
params.outdir = "output"

log.info """\
         reads:     ${params.reads}
         genome:    ${params.genome}
         singleEnd: ${params.singleEnd}
         outdir:    ${params.outdir}
         tracedir:  ${params.tracedir}
         """
         .stripIndent()

include { vcftosnpFlow } from './workflows/vcftosnp-flow.nf'

if( !params.reads ) {

  exit 1, "\nPlease give in reads via --reads <location> \n"

}

/*
 * main script flow
 */
workflow {
	
    vcftosnpFlow( params.reads )

}

/*
 * completion handler
 */
workflow.onComplete {

    log.info ( workflow.success ? "\nDone! Open the following reports in your browser --> $params.outdir/multiqc_report.html and $params.tracedir/execution_report.html\n" : "Oops .. something went wrong" )

}
