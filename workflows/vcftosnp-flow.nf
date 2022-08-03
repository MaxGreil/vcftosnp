/*
 * include requires tasks
 */
include { MINIMAP2_INDEX; MINIMAP2_TO_BAM; SAMTOOLS; PICARD; BCFTOOLS; } from '../modules/vcftosnp-tasks.nf'

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
    
    MINIMAP2_INDEX(genome_ch)
      
    MINIMAP2_TO_BAM(MINIMAP2_INDEX.out.first(), reads_ch)
    
    SAMTOOLS(MINIMAP2_TO_BAM.out)
    
    PICARD(SAMTOOLS.out.bam)
    
    BCFTOOLS(genome_ch.first(), PICARD.out.bam)
    
}
