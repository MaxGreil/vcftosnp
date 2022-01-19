process MINIMAP2 {
  publishDir "${params.outdir}/${meta}", pattern: '*.bam', mode: 'copy'

  tag "$meta"

  input:
  path(genome_ch)
  tuple val(meta), path(reads)
  
  output:
  path("*.bam")
  
  script:
  // http://broadinstitute.github.io/picard/explain-flags.html -> -F = remove, 4 = read unmapped, 8 = mate unmapped, 256 = not primary alignment
  """
  minimap2 -t $task.cpus -ax sr $genome_ch $reads \
            | samtools view -@ ${task.cpus} -bS -F 4 -F 256 - > ${meta}.${genome_ch.simpleName}.bam
  """

}
