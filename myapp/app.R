################################################################################
########### Code to Create a Shiny App of Bellevue Demographics ################
################################################################################

# 1st clear the working memory, load the libraries needed, & set the working 
# directory.
rm(list = ls())
library(tidyverse)      # For because it's awesome
library(sf)             # For loading shapefiles
# library(tigris)         # For downloading Census TIGER shapefiles
# library(tidycensus)     # For downloading/working with ACS data
# library(mapview)        # For interactive maps
library(plotly)         # For interactive figures
library(leaflet)        # For creating leaflet maps
library(shiny)          # For creating interactive data dashboards
library(tmaptools)      # For looking at color palettes
# library(readxl)         # For loading in Excel workbooks
# library(scales)         # For formatting numbers/data labels
# library(survey)         # For working with survey data
# library(srvyr)          # For using tidy commands with survey data
library(rsconnect)      # For publishing Shiny Apps
library(shinylive)
library(httpuv)
# options(scipen = 100)   # To turn off scientific notation
# options(timeout = max(1000, getOption("timeout")))  # Increase R timeout time


### Uncomment this line to set the working directory to the proper file folder ###
# directory <- paste("C:/Users/bwilliams/OneDrive - City of Bellevue/Community Data Team - Documents/",
#                    "Website/ShinyApp/DemographicProfileApp",sep="")
# dir.create(directory)
# setwd(directory)
# rm(directory)



load("DPAppData.RData")













################################################################################
############ Second Step: Use the Created Plots to Populate the App ############
################################################################################

# Create a key for the input slider we're going to create below when mapping
# the percentage of the CTs population that identifies with each racial/ethnic
# group.
groups <- c("Total Population"="Total Population",
            "Percent Non-Hispanic White"="White",
            "Percent Non-Hispanic Asian"="Asian",
            "Percent Hispanic/Latino"="Latino",
            "Percent Non-Hispanic Multiracial"="Multiracial",
            "Percent Non-Hispanic Black"="Black",
            "Percent Non-Hispanic Other"="Other",
            "Dissimilarity Index Score (2020)*"="Dissimilarity")

# Create the frontend user interface of the shiny app. Note that there are 
# separate tabs for each of the plots included with the app.
ui <- fluidPage(
  # titlePanel(p("Demographic Profile of the City of Bellevue",style="color:dodgerblue")), # Overall title
  titlePanel(div(span("Demographic Profile of the City of Bellevue", style = "color:#006598"),
                 br(),
                 span(em(h5("Bellevue welcomes the world. Our diversity is our 
                            strength. We embrace the future while respecting our 
                            past.")), style = "color:#006598")
  ),
  
  ),  
  sidebarLayout(                                                                         # Sidebar of app
    sidebarPanel(
      width=2,                                                                           # Set the sidebar width
      tags$div("This dashboard presents data about the Bellevue community. Use           
               the tabs on the right side of the dashboard to explore different 
               aspects of the City's population. Some of the tabs contain 
               additional ways to sort and filter the data. The data sources 
               used to create the visualizations in this dashboard are each 
               provided separately."),                                                   # 1st block of text
      br(),                                                                              # Short break
      tags$div("Where possible the 90% margins of error are represented by red
               bars around the estimates. These indicate the likely range of 
               uncertainty around estimates."),                                                   # 1st block of text
      br(),                                                                              # Short break
      tags$div("This dashboard was built using the",
               tags$a(href="http://shiny.rstudio.com","Shiny"),
               "framework for the",
               tags$a(href="https://www.r-project.org/","R"), 
               "programming language.")                                                  # Second block of text
    ),
    mainPanel(                                                                           # Start of main panel code
      tabsetPanel(                                                                       # Add tabs to the app
        type="tabs",                                                                     # Set tab types
        tabPanel("Race/Ethnicity (1/2)",                                                       # 1st tab - Race/Ethnicity map
                 h3("Racial & Ethnic Composition of Bellevue Population by Census Tract (2020-2024)"),   # Label the tab title
                 selectInput(inputId="var",                                              # Set the drop down options
                             label="Choose a Group to Display (Click Tract Area for Details)",
                             choices=groups),
                 leafletOutput("map"),                                      # Set plot size & object call name
                 p(strong("Source: "),                                                   # Add annotations
                   tags$a(href="https://data.census.gov/","2020-2024 American Community Survey."), 
                   "5-Year Data Profiles (Table DP05).",
                   "*Note: Dissimilarity Index scores are based on 2020 Census 
                   data & measure the within Census Tract racial/ethnic integration 
                   across Census Blocks. Scores can range from 0 - which would 
                   indicate complete group integration - to a score of 1 - which 
                   would indicate complete segregation.")),
        
        tabPanel("Race/Ethnicity (2/2)",                                                       # 1st tab - Race/Ethnicity map
                 h3("Racial & Ethnic Composition of Bellevue Population (2010-2025)"),   # Label the tab title
                 plotlyOutput("racets"),
                 p(strong("Source: "),                                                   # Add annotations
                   tags$a(href="https://data.census.gov/","2010-2025 American Community Survey."), 
                   "1-Year Data Profiles (Table DP05).")),
        
        
        tabPanel("Total Population",                                                     # 2nd tab - Population plot
                 h3("Count of Bellevue Residents Over Time (1953-2026)"),
                 plotlyOutput("popts"),
                 p(strong("Source: "), 
                   tags$a(href=paste("https://ofm.wa.gov/washington-data-research/",
                                     "population-demographics/population-estimates/",
                                     "historical-estimates-april-1-population-and-housing-state-counties-and-cities",
                                     sep=""),
                          "Washington State Office of Financial Management."), 
                   "April 1 Postcensal Estimates of Population (1960-Present); ",
                   tags$a(href="https://eastsideheritagecenter.org/gift-shop/bellevue-timeline",
                          "Bellevue Timeline."),
                   "The Story of Washington's Leading Edge City From Homesteads 
                   to High Rises, 1863-2003.")),
        
        
        tabPanel("Age & Sex",                                                            # 3rd tab - Age & Sex plot
                 h3("Count of Bellevue Residents by Age & Sex (2025)"),
                 plotlyOutput("age"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","2025 American Community Survey."), 
                   "1-Year Detailed Tables (Table B01001).")),
        
        tabPanel("Age & Race/Ethnicity",                                                 # 4th tab - Age & Race/Ethnicity tab
                 h3("Count of Bellevue Residents by Age & Race/Ethnicity (2020-2024)"),
                 plotlyOutput("rcage"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","2020-2024 American Community Survey."), 
                   "5-Year Detailed Tables (Table B01001B-I).")),
        
        tabPanel("Age Over Time",                                                 # 4th tab - Age & Race/Ethnicity tab
                 h3("Percentage of Bellevue Residents by Age Group (2010-2025)"),
                 plotlyOutput("ageTS"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","American Community Survey."), 
                   "2010-2025 1-Year Subject Tables & Data Profiles (Tables S0101 & DP05).")),
        
        
        tabPanel("Place of Birth/Citizenship",                                           # 5th tab - Place of Birth/Citizenship tab
                 h3("Count of Bellevue Residents by Place of Birth/Citizenship (1970-2025)"),
                 plotlyOutput("pob"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","U.S. Census Bureau."), 
                   "1970-1990 Decennial Censuses (Tables NT25, NTPB9, NT33, NP37,
                   & NP42). Retrieved via IPUMS NHGIS, University of Minnesota, ",
                   tags$a(href="www.nhgis.org","www.nhgis.org;"),
                   tags$a(href="https://data.census.gov/","U.S. Census Bureau."), 
                   "2000 Decennial Census (Table DP2);", 
                   tags$a(href="https://data.census.gov/","American Community Survey."), 
                   "2010-2025 1-Year Data Profiles (Table DP02).")),
        
        tabPanel("English Speaking Ability (1/2)",                                      # 6th tab - 1st English Proficiency tab
                 h3("Percentage of Bellevue Residents by Primary Language Spoken at
                    Home & English Proficiency (1980-2025)"),
                 plotlyOutput("bvspoke"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","U.S. Census Bureau."), 
                   "1980-1990 Decennial Censuses (Tables NT27 & NP28). Retrieved 
                   via IPUMS NHGIS, University of Minnesota, ",
                   tags$a(href="www.nhgis.org","www.nhgis.org;"),
                   tags$a(href="https://data.census.gov/","U.S. Census Bureau."), 
                   "2000 Decennial Census (Table DP2);", 
                   tags$a(href="https://data.census.gov/","American Community Survey."), 
                   "2010-2025 1-Year Data Profiles (Table DP02).")),
        
        tabPanel("English Speaking Ability (2/2)",                                      # 7th tab - 2nd English Proficiency tab
                 h3("Percentage of Residents by Primary Language Spoken at
                    Home & English Proficiency (2025)"),
                 plotlyOutput("spokecomp1"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","2025 American Community Survey."), 
                   "1-Year Data Profiles (Table DP02).")),
        
        tabPanel("Household Type & Age",                                                # 8th tab - 2nd English Proficiency tab
                 h3("Count of Bellevue Households by Household Type & Head of 
                    Household Age (2025)"),
                 plotlyOutput("hhead"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","2025 American Community Survey."), 
                   "1-Year Detailed Tables (Table B25011).")),
        
        tabPanel("Top 10 Languages",                                                    # 9th tab - Language tab
                 h3("Count of Bellevue Area Residents by Primary Language & 
                    English Proficiency (2020-2024)"),
                 plotlyOutput("pumslang"),
                 p(strong("Source: "), 
                   tags$a(href="https://data.census.gov/","2020-2024 American Community Survey."), 
                   "5% PUMS Microdata Sample for Greater Bellevue PUMA.")),
        
        tabPanel("Quick Facts",                                                     # 2nd tab - Population plot
                 h3("Quick Facts About the City of Bellevue"),
                 tableOutput("qfacts"),
                 p(strong("Source: "),
                   tags$a(href=paste("https://ofm.wa.gov/washington-data-research/",
                                     "population-demographics/population-estimates/",
                                     "historical-estimates-april-1-population-and-housing-state-counties-and-cities",
                                     sep=""),
                          "Washington State Office of Financial Management."),
                   "April 1 Postcensal Estimates of Population (2026); ",
                   tags$a(href="https://data.census.gov/","2020-2024 American Community Survey."),
                   "5-Year Detailed Tables (Table B01001).",
                   tags$a(href="https://data.census.gov/","2025 American Community Survey."),
                   "1-Year Detailed Tables & Data Profiles (Tables B19013, DP02, & DP05).")),
        
        
      )
    )
  )
)



# Now create the backend server functionality to populate the shiny app
# palette_explorer()                      # Uncomment to explore palette options
server <- function(input,output){                                   # Create the function
  group_to_map <- reactive({                                        # 1st tab plot - Race/Ethnicity map
    filter(bvue_tracts_map,variable==input$var)                      # Filter the data according to drop down selection
  })
  output$map <- renderLeaflet({                                     # Create the map/focus on Bellevue area
    leaflet(options=leafletOptions(zoomControl=FALSE)) %>%
      setView(-122.156,47.585, zoom=11) %>%
      addProviderTiles('Stadia.AlidadeSmooth') 
  })
  observeEvent(input$var, {                                         # Fill the map with the selected data
    pal <- colorNumeric("inferno",reverse = TRUE,group_to_map()$`e`)
    leafletProxy("map") %>%
      clearShapes() %>%
      clearControls() %>%
      addPolygons(data=group_to_map(),
                  color= ~pal(`e`),
                  weight=0.5,
                  fillOpacity=0.5,
                  smoothFactor=0.2,
                  popup=~paste0("Estimate: ",`e`,
                                "<br>",
                                "MOE: ±",`moe`)) %>%
      addLegend(
        position="bottomright",
        pal=pal,
        values=group_to_map()$`e`,
        title="Estimate"
      )
  })
  
  output$racets <- renderPlotly({                                   # 2nd tab plot - Population
    racetsplotly
  })
  
  output$popts <- renderPlotly({                                   # 2nd tab plot - Population
    popplotly
  })
  
  output$age <- renderPlotly({                                     # 3rd tab plot - Age/Sex
    ageplotly
  })
  
  output$rcage <- renderPlotly({                                   # 4th tab plot - Age & Race/Ethnicity
    rcageplotly
  })

  output$ageTS <- renderPlotly({                                   # 4th tab plot - Age & Race/Ethnicity
    ageTSplotly
  })
  
  output$pob <- renderPlotly({                                     # 5th tab plot - Place of Birth
    pobplotly
  })
  
  output$bvspoke <- renderPlotly({                                 # 6th tab plot - English Proficiency (1/2)
    bvspokeplotly
  })
  
  output$spokecomp1 <- renderPlotly({                              # 7th tab plot - English Proficiency (2/2)
    spokecompplotly
  })
  
  output$hhead <- renderPlotly({                                   # 8th tab plot - Household Age/Type
    hheadplotly
  })
  
  output$pumslang <- renderPlotly({                                # 9th tab plot - Household Age/Type
    langplotly
  })
  
  output$qfacts <- renderTable({
    facts
  })
}



# Now connect the ui to the server function to create the App
shinyApp(ui=ui,server=server)

# rsconnect::deployApp()
# rsconnect::migrateToConnectCloud(appPath=paste0("C:/Users/bwilliams/OneDrive - City of Bellevue/",
#                                                 "Community Data Team - Documents/Website/ShinyApp/",
#                                                 "DemographicProfileApp"),
#                                  contentId = "01a05f2d-3d27-b565-c359-71d165fd5a63")




















