/*
 * include requires tasks
 */
include { MINIMAP2; } from '../modules/vcftosnp-tasks.nf'

/*
 * define the data analysis workflow
 */
workflow vcftosnpFlow {
    // required inputs
    take:
      reads
    // workflow implementation
    main:
    
    if( params.genome ) {
        Channel
          .fromPath( params.genome )
          .ifEmpty { exit 1, "genome - ${params.genome} was empty - no input file supplied" }
          .set { genome_ch }
    }
      
    if( params.singleEnd ){
        Channel
          .fromPath( reads )
          .ifEmpty { exit 1, "reads - ${params.reads} was empty - no input files supplied" }
          .map { file -> tuple(file.simpleName, file) }
          .set { reads_ch }
    } else {
        Channel
          .fromFilePairs( reads )
          .ifEmpty { exit 1, "reads - ${params.reads} was empty - no input files supplied" }
          .set { reads_ch }
    }
      
    MINIMAP2(genome_ch, reads_ch)
    
}
