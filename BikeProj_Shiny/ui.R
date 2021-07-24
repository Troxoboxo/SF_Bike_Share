library(shiny)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(igraph)
library(visNetwork)
library(png)
library(gifski)
library(networkD3)
library(leaflet)
library(leaflet.extras)
library(DT)

# Define UI for application that draws a histogram
shinyUI(
    fluidPage(
        
        theme = shinytheme("superhero"),
        
        tags$style(HTML("
        .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter, .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_processing, .dataTables_wrapper .dataTables_paginate, .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
        color: #ffffff;
        }
        .dataTables_wrapper .dataTables_paginate .paginate_button{box-sizing:border-box;display:inline-block;min-width:1.5em;padding:0.5em 1em;margin-left:2px;text-align:center;text-decoration:none !important;cursor:pointer;*cursor:hand;color:#ffffff !important;border:1px solid transparent;border-radius:2px}
        .dataTables_length select { ###To change text and background color of the `Select` box ###
               color: #0E334A;
               background-color: #0E334A
               }
        .dataTables_filter input { ###To change text and background color of the `Search` box ###
                color: #0E334A;
               }
    
        thead {
        color: #ffffff;
        }
    
         tbody {
        color: #000000;
        }")),
        
        fluidRow(
            column(2,
                uiOutput('Station_Sel_UI')
            ),
            column(1, 
                radioButtons(inputId = 'Subscription_type', label = 'Subscription Type', 
                             choices = c('All', 'Subscriber', 'Customer')),
            ),
            column(1,
                radioButtons(inputId = 'Weekday_type', label = 'Week day/end', 
                             choices = c('All','Weekday', 'Weekend'))
            ),
            column(1, offset = 1, 
                radioButtons(inputId = 'Rain_type', label = 'Weather Conditions', 
                             choices = c('All' = 'All', 'Rain' = 'Rain', 'No Rain' = 'No_Rain'))
            ),
            column(1,
                   radioButtons(inputId = 'Temp_type', label = '', 
                                choices = c('All' = 'All', 'High Temperature' = 'High_Temp', 'Medium Temperature' = 'Medium_Temp', 
                                            'Low Temperature' = 'Low_Temp'))
            ),
            column(1,
                   radioButtons(inputId = 'Humidity_type', label = '', 
                                choices = c('All' = 'All', 'High Humidity' = 'High_Humidity', 'Medium Humidity' = 'Medium_Humidity', 
                                            'Low Humidity' = 'Low_Humidity'))
            ),
            column(1,
                   radioButtons(inputId = 'Cloudy_type', label = '', 
                                choices = c('All' = 'All', 'Clear Skies' = 'Not_Cloudy', 'Cloudy' = 'Cloudy'))
            ),
            column(1,
                   radioButtons(inputId = 'Visibility_type', label = '', 
                                choices = c('All' = 'All', 'High Visibility' = 'High_Visibility', 'Low Visibility' = 'Low_Visibility'))
            ),
            column(1, 
                   uiOutput('Date_Slider_UI')
            )
        ),
        
        hr(), 
        
        fluidRow(
            
            tabsetPanel(type = 'pills', 
                        tabPanel('Network', visNetworkOutput('network_vis')), 
                        tabPanel('Map', leafletOutput('leaflet_vis'))
                        )
            
        ),
        
        hr(), 
        
        fluidRow(
            
            DT::dataTableOutput('testtable')
            
        )


))
