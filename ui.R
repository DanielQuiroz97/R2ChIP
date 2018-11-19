#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)



## ui.R ##


dbHeader <- dashboardHeader(title = "R2ChIP"
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem('Home', tabName = 'home', icon = icon('home')),
    menuItem("Single bed analysis", tabName = "singleBed",
             icon = icon("upload"), startExpanded = T,
             menuSubItem('Profiling', 'profiling'),
             menuSubItem('Peak annotation', 'annotation')),
    menuItem('Multiple bed analysis', tabName = 'multipleBed', 
             icon = icon("play"), startExpanded = F,
             menuSubItem('Profiling', 'comparison'),
             menuSubItem('Peak annotation', 'annotationMul')),
    br(), br(), br(), br(), br(), br(), br(), br(), br(), hr(),
    menuItem('Feedback & suggestion', icon = icon('envelope-o'),
             href = 'mailto:?cristian.quiroz@ikiam.edu.ec?subject=Feedback on ChIP app'),
    menuItem('Source code', icon = icon('file-code-o'),
             href = 'https://github.com')
  )
  
)

itemHome <- tabItem(tabName = 'home',
                    fluidRow(
                      column(width = 3),
                      column(width = 5,
                             h2('ChIP-seq profiling, annotation and visualization'),
                             align = 'center'),
                      column(width = 4)
                    ),
                    
                    hr(),
                    fluidRow(
                      column(width = 12,
                             box(width = 12, title = 'Introduction', status = 'danger',
                                 solidHeader = T,
                                 h4(div(HTML('This web application was designed to run
                                             ChIP-seq peak profiling, comparison and visualization. The main back end functionalities of
                                             this web application is based on
                                             <a href = "https://academic.oup.com/bioinformatics/article/31/14/2382/255379"> ChIPseeker</a> (1) package,
                                             as well specific features are retrieved from 
                                             <a href = "https://academic.oup.com/bioinformatics/article/31/4/608/2748221"> DOSE</a> (2), and
                                             <a href = "https://www.ncbi.nlm.nih.gov/pubmed/22455463"> clusterProfiler</a> (3).
                                             Basically, you can perform two types of analysis; an exploratory analysis an peak annotation.
                                             In the exploratory, or profiling analysis, you will check what is inside of your bed file, whereas
                                             in peak annotation, you will see position and strand information of nearest genes'))),
                                 
                                 h4(div(HTML('First of all, you have to upload your bed file in the profiling item, at the side left bar.
                                             Once you already upleaded data, you have to click on run analysis button. It could take different
                                             times before finish the back end analysis for different bed files. On the other hand, if you 
                                             decide your bed file is ok, you can continue with peak annotation step. Then, go to the main 
                                             menu and select peak annotation item and click on start button. Several plots will be presented and
                                             you can choose which is the best representation for your data.'))),
                                 
                                 h4('The source code is stored in two parts'),
                                 HTML('<ul> 
                                      <li> <a href = \"https://github\"> github  </a></li>')
                                 ),
                             fluidRow(column(width = 8,
                                             box(width = 12, title = 'References', status = "info", solidHeader = T,
                                                 HTML("<ol> 
                                                        <li>  Guangchuang,Y., Li-Geng,H. (2015) ChIPseeker: an R/Bioconductor package for ChIP peak 
                                                              annotation, comparison and visualization. <i> Bioinfor</i>. <b>31</b>. 2382-2383 </li>
                                                        <li>  Guangchuang,Y., Li-Gen,W., Guang-Rong,Y., Qing-Yu,H. (2015) DOSE: an R/Bioconductor
                                                              package for Disease Ontology Semantic and Enrichment Analysis. <i> Bioinfor</i>. <b>31</b>. 608-609</li>
                                                        <li>  Guangchuang,Y., Li-Gen,W., Yanyan,H., Qing-Yu,H. (2012) clusterProfiler> an R package for 
                                                              comparing biological themes among gnene cluster. <i> OMICS: Jour. Integ. Biol.</i>
                                                              <b>16</b>. 284-287   </li>
                                                      </ol>"))),
                                      column(width = 4,
                                             box(width = 12, title = 'Source code', status = "info", solidHeader = T,
                                                 HTML("The source code is available in two repositories
                                                       <ul>
                                                         <li> <a href=https://www.w3schools.com>Visit Dropbox</a>  </li>
                                                        <li> <a href=https://www.w3schools.com>Visit github</a> </li>  
                                                      </ul>")))),
                             a(href = 'http://ikiam.edu.ec/', 
                               img(src = 'Logotipo_Ikiam.png', width = 250, height = 200))
                             
                             
                      )
                    )
)

itemProfiling <- tabItem(tabName = 'profiling', 
                         h1('Chip-seq Data Profiling'),
                         
                         column(width = 4, 
                                fluidRow(
                                  box(width = 12, title = 'Upload yor .bed file',
                                      solidHeader = T, status = 'danger',
                                      helpText('Select a sequenced bed file to continue 
                                               with following analysis. Just .bed.gz files are allowed.'),
                                      fileInput('bed1', 'Choose your bed file'),
                                      
                                      selectInput('selectSystem', 
                                                  label = 'Select Biological System',
                                                  choices = list('Homo sapiens' = 'Hsapiens',
                                                                 'Mus musculus' = 'Mmusculus',
                                                                 'Danio rerio'  = 'Drerio',
                                                                 'Gallus gallus'= 'Ggallus',
                                                                 'Macaca mulata'= 'Mmulatta',
                                                                 'Rattus norvegicus' = 'Rnorvegicus',
                                                                 'Sacharomices cerevisiae' = 'Scerevisiae',
                                                                 'Sus scrofa' = 'Sscrofa')),
                                      
                                      actionButton('run', 'Run Analysis', icon = icon('play')))
                                )
                         ),
                         column( width = 8,
                                 fluidRow(
                                   box(width = 12, title = 'Readed Peaks', solidHeader = T,
                                       status = 'info', 
                                       verbatimTextOutput('readedPeaks'))
                                 ),
                                 fluidRow(
                                   box( width = 12, title = 'Profiling plots',
                                        solidHeader = T, status = 'info',
                                        tabBox(title = '', width = 12,
                                               tabPanel(title = tagList(shiny::icon('bar-chart'), 'Coverage'),
                                                        helpText('This plot presents peak locations over the whole genome \n'),
                                                        plotOutput('coverage')
                                               ),
                                               tabPanel(title = tagList(shiny::icon('dna'), 'Binding TSS Regions'),
                                                        helpText('This is the representation of peaks binding to TSS regions'),
                                                        plotOutput('TSS') 
                                               ),
                                               tabPanel(title = tagList(shiny::icon('chart-area'), 'Average Binding TSS Regions'),
                                                        helpText('This is the representation of average peaks binding to TSS regions'),
                                                        plotOutput('averageTSS') 
                                               )
                                        )
                                   )
                                   
                                 )
                         )
                         
)

itemAnnotation <- tabItem(tabName = 'annotation',
                          column(width = 4,
                                 box(width = 12, title = 'Peak Annotation Initialization',
                                     solidHeader = T, status = 'danger',
                                     helpText('Peak annotation analysis will be performed for your previously bed file uploaded.
                                   By default, H. sapiens sapiens genome will be used. \n If you want to start this step,
                                   please, click on Start Annotation button'),
                                     actionButton('annotationBT', 'Start Annotation', icon = icon('play'))),
                                 
                                 box(width = 12, title = 'Peak Annotation Visualization',
                                     solidHeader = T, status = 'danger',
                                     helpText('There are six different types of plots
                                              to visualize anottation, please select one'),
                                     selectInput('singleAnnotPlot', 'Type of Annotation Plot',
                                                 choices =  list('Bar char' = 'barchar',
                                                                 'Upset' = 'upset',
                                                                 'Dist to TSS' = 'disttotss',
                                                                 'Pie' =  'pie',
                                                                 'Ven pie' = 'venpie')))
                          ),
                          column(width = 8,
                                 fluidRow(
                                   box(width = 12, title = 'Annotated Peaks',
                                       solidHeader = T, status = 'info',
                                       verbatimTextOutput('Annotation')),
                                   box(width = 12, title = 'Annotation Plot',
                                       solidHeader = T,status = 'info',
                                       plotOutput('SingleAnnoPlot',
                                                  height = '200px'))
                                 )
                          ))


itemComparison <- tabItem(tabName = 'comparison',
                          h1('Multiple sample comparison'),
                          column( width = 4,
                            #scriptHeaders(),
                            box(width = 12, title = 'Upload yor .bed files',
                                solidHeader = T, status = 'danger',
                                fileInput('multipleBed', 'Choose File',multiple = F, 
                                          accept = c('.zip', 'zip')),
                                helpText('Select multiple bed files to continue 
                                         with following analysis. Just .bed.gz files are allowed.'),
                                
                                selectInput('ComSelectSystem', 
                                            label = 'Select Biological System',
                                            choices = list('Homo sapiens' = 'Hsapiens',
                                                           'Mus musculus' = 'Mmusculus',
                                                           'Danio rerio'  = 'Drerio',
                                                           'Gallus gallus'= 'Ggallus',
                                                           'Macaca mulata'= 'Mmulatta',
                                                           'Rattus norvegicus' = 'Rnorvegicus',
                                                           'Sacharomices cerevisiae' = 'Scerevisiae',
                                                           'Sus scrofa' = 'Sscrofa')),
                                actionButton('buttComparison', 'Run Analysis', icon = icon('play'))
                                )
                          ),
                          
                          column( width = 8,
                            box( width = 12, solidHeader = T, 
                                 title = 'Profiling Plots', status = 'info',
                            tabBox(title = '', width = 12,
                                   tabPanel(title = tagList(shiny::icon('bar-chart'), 'Coverage'),
                                            checkboxInput('facet', 'Display coverage plot separately for each bed file',
                                                          value = F),
                                            helpText('This plot presents peak locations over the whole genome \n'),
                                            plotOutput('MulAvgProf', height = '800px')
                                   ),
                                   tabPanel(title = tagList(shiny::icon('dna'), 'Matrix Heatmap'),
                                            helpText('This is the representation of peaks binding to TSS regions'),
                                            plotOutput('MulTSS', height = '800px') 
                                   )
                            )
                          )
                          )
)

MulAnnotation <- tabItem(tabName = 'annotationMul',
                         column(width = 4,
                                box(width = 12, title = 'Annotation Initialization',
                                    solidHeader = T, status = 'danger',
                                    helpText('Peak annotation analysis will be performed for your
                                             previously bed file uploaded. By default, 
                                             H. sapiens sapiens genome will be used. 
                                             If you want to start this step, please, 
                                             click on Start Annotation button'),
                                    actionButton('MulAnnotation', 'Start Multiple Annotation',
                                                 icon('play'))
                                    ),
                                box(width = 12, title = 'Multiple Annotation Visualization',
                                    solidHeader = T, status = 'danger',
                                    helpText('There are six different types of plots 
                                             to visualize anottation, please select one'),
                                    selectInput('MulAnnotVis', 'Type of Annotation Plot', 
                                                choices = list('Bar char' = 'barchar',
                                                               'Distance to TSS' =  'tts'))
                                    
                                    ),
                                box(width = 12, title = 'Venn Diagram',
                                    solidHeader = T, status = 'danger', 
                                    helpText('Once you have performed peak annotation, you 
                                             can check the overlaped peaks by making a 
                                             venn diagram. If you would like make venn diagram, 
                                             please click on start button'),
                                    actionButton('vennDiagram', 'Make Venn Diagram',
                                                 icon(''))
                                    )
                                ),
                         column(width = 8,
                                box(width = 12,title =  'Peak Annotation', 
                                    solidHeader = T, status = 'info',
                                    plotOutput('MulAnnoPlt')),
                                box(width = 12,title =  'Functional Enrichment',
                                    solidHeader = T, status = 'info',
                                    plotOutput('MulEnrichPlt')),
                                box(width = 12,title =  'Overlap Peaks',
                                    solidHeader = T, status = 'info',
                                    plotOutput('MulVenn'))
                                )
                         
                         )

body <- dashboardBody(
  tabItems(
    itemHome,
    itemProfiling,
    itemAnnotation,
    itemComparison,
    MulAnnotation
  )
)

# Put them together into a dashboardPage
dashboardPage(
  skin = 'blue',
  dbHeader,
  sidebar,
  body
)