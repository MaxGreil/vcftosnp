process MINIMAP2_INDEX {

  tag "$genome_ch.simpleName"

  input:
  path(genome_ch)
  
  output:
  path("*.mmi")
  
  script:
  """
  minimap2 -t $task.cpus -d ${genome_ch.simpleName}.mmi $genome_ch
  """

}

process MINIMAP2_TO_BAM {
  
  tag "$meta"

  input:
  path(genome_ch)
  tuple val(meta), path(reads)
  
  output:
  tuple val(meta), path("*.bam")
  
  script:
  // http://broadinstitute.github.io/picard/explain-flags.html -> -F = remove, 4 = read unmapped
  """
  minimap2 -t $task.cpus -ax sr $genome_ch $reads \
            | samtools view -@ $task.cpus -bS -F 4 - > ${meta}.bam
  """

}

process SAMTOOLS {
  publishDir "${params.outdir}/${meta}", pattern: '*.sorted.bam.flagstat', mode: 'copy'
  
  tag "$meta"
  
  input:
  tuple val(meta), path(bam)
  
  output:
  path("*.sorted.bam"), emit: bam
  path("*.sorted.bam.flagstat"), emit: flagstat
  
  script:
  """
  samtools sort -@ $task.cpus $bam > ${meta}.sorted.bam
  samtools flagstat ${meta}.sorted.bam > ${meta}.sorted.bam.flagstat
  """

}

process PICARD {
  publishDir "${params.outdir}/${sorted_bam.simpleName}", pattern: '*.metrics.txt', mode: 'copy'
  publishDir "${params.outdir}/${sorted_bam.simpleName}", pattern: '*.sorted.md.bam', mode: 'copy'
  publishDir "${params.outdir}/${sorted_bam.simpleName}", pattern: '*.sorted.md.bai', mode: 'copy'
  
  tag "$sorted_bam.simpleName"

  input:
  path(sorted_bam)
  
  output:
  tuple path("*.sorted.md.bam"), path("*.sorted.md.bai"), emit: bam
  path("*.metrics.txt"), emit: metrics
  
  script:
  def avail_mem = 3
  if (!task.memory) {
    log.info '[Picard MarkDuplicates] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
  } else {
    avail_mem = task.memory.giga
  }
  """
  picard -Xmx${avail_mem}g \
         MarkDuplicates \
         ASSUME_SORTED=true \
         CREATE_INDEX=true \
         I=$sorted_bam \
         O=${sorted_bam.simpleName}.sorted.md.bam \
         M=${sorted_bam.simpleName}.MarkDuplicates.metrics.txt
  """

}

process BCFTOOLS {
  publishDir "${params.outdir}/${sorted_bam.simpleName}", pattern: '*.vcf', mode: 'copy'

  tag "$sorted_bam.simpleName"

  input:
  path(genome_ch)
  tuple path(sorted_bam), path(sorted_bai)
  
  output:
  path("*.vcf")
  
  script:
  // -Ou = output-type uncompressed BCF, -mv = multiallelic-caller variants-only, -Ob = output-type compressed BCF
  """
  gunzip -c $genome_ch > ${genome_ch.simpleName}.fa
  
  bcftools mpileup --threads $task.cpus -Ou -f ${genome_ch.simpleName}.fa $sorted_bam \
  | bcftools call --threads $task.cpus -mv -Ob - \
  | bcftools view --threads $task.cpus - > ${sorted_bam.simpleName}.vcf
  """

}
