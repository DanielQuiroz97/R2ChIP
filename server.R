library(shiny)
library(ChIPseeker)
library(clusterProfiler)
library(magrittr)

is.bed <- function(filename) {
  nameln <- nchar(filename)
  extention <- substring(filename, nameln - 6, nameln)
  extention <- extention %in% c(".gz", "bed.gz", "bed", ".zip")
  return(all(extention))
}

shinyServer(function(input, output) {
  
  #### Profiling ####
  
  bedPeaks <- eventReactive(input$run,{
    showModal(modalDialog(title = "Single bed",
                          footer = "ChIP peaks are being analyzed"))
    peakFile <- input$bed1$datapath
    peaks <- readPeakFile(peakFile)
    
    return(peaks)
  })
  
  txdb <- eventReactive(input$annotationBT, {
    txdb <- switch (input$selectSystem,
                    'Hsapiens' = {
                      library(TxDb.Hsapiens.UCSC.hg19.knownGene)
                      txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene},
                    
                    'Mmusculus' = {
                      library(TxDb.Mmusculus.UCSC.mm10.knownGene)
                      txdb <- TxDb.Mmusculus.UCSC.mm10.knownGene},
                   
                     'Drerio' = {
                      library(TxDb.Drerio.UCSC.danRer10.refGene)
                      txdb <- TxDb.Drerio.UCSC.danRer10.refGene},
                    
                    'Ggallus' = {
                      library(TxDb.Ggallus.UCSC.galGal4.refGene)
                      txdb <- TxDb.Ggallus.UCSC.galGal4.refGene},
                    
                    'Mmulatta' = {
                      library(TxDb.Mmulatta.UCSC.rheMac8.refGene)
                      txdb <- TxDb.Mmulatta.UCSC.rheMac8.refGene},
                    
                    'Rnorvegicus'  = {
                      library(TxDb.Rnorvegicus.UCSC.rn5.refGene)
                      txdb <- TxDb.Rnorvegicus.UCSC.rn5.refGene },
                    
                    'Scerevisiae' = {
                      library(TxDb.Scerevisiae.UCSC.sacCer2.sgdGene)
                      txdb <- TxDb.Scerevisiae.UCSC.sacCer2.sgdGene},
                    
                    'Sscrofa' = {
                      library(TxDb.Sscrofa.UCSC.susScr3.refGene)
                      txdb <- TxDb.Sscrofa.UCSC.susScr3.refGene} )
    txdb
  })
  
  promoter <- eventReactive(input$run, {
    promoter <- switch (input$selectSystem,
                        'Hsapiens' = {load('ref_genomes/promoterHsapiens.RData'); promoter},
                        'Mmusculus' = {load('ref_genomes/promoterMmusculus.RData'); promoter},
                        'Drerio' = {load('ref_genomes/promoterDrerio.RData.RData'); promoter},
                        'Ggallus' = {load('ref_genomes/promoterGgallus.RData'); promoter},
                        'Mmulatta' = {load('ref_genomes/promoterMmulata.RData'); promoter},
                        'Rnorvegicus'  = {load('ref_genomes/promoterRnorvegicus.RData'); promoter},
                        'Scerevisiae' = {load('ref_genomes/promoterScerevisiae.RData'); promoter},
                        'Sscrofa' = {load('ref_genomes/promoterSscrofa.RData'); promoter} )
    promoter
  })


  output$readedPeaks <- renderPrint({
    input$run
    print( isolate(bedPeaks()) )
  })


  output$coverage <- renderPlot({
    input$run
    cov_plot <- covplot(isolate(bedPeaks()))
    removeModal()
    return(cov_plot)
  })

  tagMatrix <- reactive({
    tagMatrix <- getTagMatrix(bedPeaks(), windows =  promoter())
    tagMatrix
    
  })

  output$TSS <- renderPlot({
    tagHeatmap(tagMatrix(),  xlim=c(-3000, 3000), color="blue")

  })


  output$averageTSS <- renderPlot({
    plotAvgProf(tagMatrix(), xlim=c(-3000, 3000),
                conf = 0.95, resample = 100,
                xlab="Genomic Region (5'->3')",
                ylab = "Read Count Frequency")

  })

  #### Annotation ####
  PeakAnnotation <- eventReactive(input$annotationBT, {
    peakAnno <- annotatePeak(input$bed1$datapath,
                             tssRegion=c(-3000, 3000),
                            TxDb=txdb())
    peakAnno
  })
  
  output$Annotation <- renderPrint({
    input$annotationBT
    isolate(print(PeakAnnotation()))
  })
  
  output$SingleAnnoPlot <- renderPlot({
    validate(
      need(!is.null(input$annotationBT), 'Start Annotation')
    )
    plt <- switch (input$singleAnnotPlot,
      'barchar' = { 
          plt <- plotAnnoBar(PeakAnnotation())
          plt
        },
      'upset' = {
          plt <- upsetplot(PeakAnnotation(), vennpie = T)
          plt
      },
      'disttotss' = {
          plt <- plotDistToTSS(PeakAnnotation())
          plt
      },
      'pie' = {
          plt <- plotAnnoPie(PeakAnnotation())
          plt
      },
      'venpie' = {
          plt <- vennpie(PeakAnnotation())
          plt

      }
    )
    plt
  })
  
  
  
  
  #### Multiple Bed Profiling ####
  
  
  MulPromoter <- eventReactive(input$buttComparison, {
    promoter <- switch (input$ComSelectSystem,
                        'Hsapiens' = {load('ref_genomes/promoterHsapiens.RData'); promoter},
                        'Mmusculus' = {load('ref_genomes/promoterMmusculus.RData'); promoter},
                        'Drerio' = {load('ref_genomes/promoterDrerio.RData.RData'); promoter},
                        'Ggallus' = {load('ref_genomes/promoterGgallus.RData'); promoter},
                        'Mmulatta' = {load('ref_genomes/promoterMmulata.RData'); promoter},
                        'Rnorvegicus'  = {load('ref_genomes/promoterRnorvegicus.RData'); promoter},
                        'Scerevisiae' = {load('ref_genomes/promoterScerevisiae.RData'); promoter},
                        'Sscrofa' = {load('ref_genomes/promoterSscrofa.RData'); promoter} )
    promoter
  })
  
  Multxdb <- eventReactive(input$MulAnnotation, {
    txdb <- switch (input$selectSystem,
                    'Hsapiens' = {
                      library(TxDb.Hsapiens.UCSC.hg19.knownGene)
                      txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene},
                    
                    'Mmusculus' = {
                      library(TxDb.Mmusculus.UCSC.mm10.knownGene)
                      txdb <- TxDb.Mmusculus.UCSC.mm10.knownGene},
                    
                    'Drerio' = {
                      library(TxDb.Drerio.UCSC.danRer10.refGene)
                      txdb <- TxDb.Drerio.UCSC.danRer10.refGene},
                    
                    'Ggallus' = {
                      library(TxDb.Ggallus.UCSC.galGal4.refGene)
                      txdb <- TxDb.Ggallus.UCSC.galGal4.refGene},
                    
                    'Mmulatta' = {
                      library(TxDb.Mmulatta.UCSC.rheMac8.refGene)
                      txdb <- TxDb.Mmulatta.UCSC.rheMac8.refGene},
                    
                    'Rnorvegicus'  = {
                      library(TxDb.Rnorvegicus.UCSC.rn5.refGene)
                      txdb <- TxDb.Rnorvegicus.UCSC.rn5.refGene },
                    
                    'Scerevisiae' = {
                      library(TxDb.Scerevisiae.UCSC.sacCer2.sgdGene)
                      txdb <- TxDb.Scerevisiae.UCSC.sacCer2.sgdGene},
                    
                    'Sscrofa' = {
                      library(TxDb.Sscrofa.UCSC.susScr3.refGene)
                      txdb <- TxDb.Sscrofa.UCSC.susScr3.refGene} )
    txdb
  })
  
  MultipleBedsFiles <- eventReactive(input$buttComparison,{
    showModal(modalDialog(title = "Multiple Bed",
                          footer = "ChIP peaks are being analyzed"))
    peakFile <- input$multipleBed$datapath
    unzip(peakFile, overwrite = F)
    peakFile <- list.files(pattern = '.bed.gz$', recursive = F)
    peakFile
  })
  
  MultipleBeds <- eventReactive(input$buttComparison, {
    bed_files <- MultipleBedsFiles()
    peaks <- lapply(bed_files, getTagMatrix,
                    windows =  MulPromoter())
    bed_names <- bed_files %>%
      sapply(function(x) strsplit(x, split = "[.]")[[1]][1] )
    names(peaks) <- bed_names
    return(peaks)
  })
  
  output$MulAvgProf <- renderPlot({
    input$buttComparison
    fct <- ifelse(input$facet, 'row', 'none')
    maverage_plot <- plotAvgProf(isolate(MultipleBeds()),
                xlim = c(-3000, 3000), facet = fct)
    removeModal()
    return(maverage_plot)
  })
  
  output$MulTSS <- renderPlot({
    input$buttComparison
    tagHeatmap(isolate(MultipleBeds()), xlim = c(-3000, 3000),
               color = NULL)
  })
  
  #### Multiple Bead Annotation #### 
  MulPeakAnno <- eventReactive(input$MulAnnotation, {
    peakAnnoList <- lapply(MultipleBedsFiles(),
                           annotatePeak, TxDb = Multxdb())
    peakAnnoList
  })
  
  
  output$MulAnnoPlt <- renderPlot({
    input$MulAnnotation
    plt <-  switch (input$MulAnnotVis,
                    'barchar' = plotAnnoBar( isolate(MulPeakAnno()) ),
                    'tts' = plotDistToTSS( isolate(MulPeakAnno())  )
    )
    plt
  })
  
  
  
  output$MulVenn <- renderPlot({
    input$vennDiagram
    genes= lapply(isolate( MulPeakAnno() ), 
                  function(i) as.data.frame(i)$geneId)
    plt <- vennplot(genes)
    plt
  })
  
})
