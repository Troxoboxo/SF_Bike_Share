library(shiny)
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


df <- read.csv('data/master.csv', header = TRUE)
df2 <- read.csv('data/station.csv', header = TRUE)


shinyServer(function(input, output, session) {

    # Reactive Elements
    Trip_data <- reactive({
        req(input$Station_Sel)
        
        trip_df <- df
        
        # Filter based on inputs 
        trip_df <- trip_df %>% filter( start_station_name == input$Station_Sel )
        if (input$Subscription_type != 'All') { trip_df <- trip_df %>% filter( subscription_type == input$Subscription_type )}
        if (input$Weekday_type!= 'All') { trip_df <- trip_df %>% filter( weekday == input$Weekday_type ) }
        if (input$Rain_type != 'All') { trip_df <- trip_df %>% filter( rain_node == input$Rain_type ) }
        if (input$Temp_type != 'All') { trip_df <- trip_df %>% filter( temp_node == input$Temp_type ) }
        if (input$Humidity_type != 'All') { trip_df <- trip_df %>% filter( humidity_node == input$Humidity_type ) }
        if (input$Cloudy_type != 'All') { trip_df <- trip_df %>% filter( cloudy_node == input$Cloudy_type) }
        if (input$Visibility_type != 'All') { trip_df <- trip_df %>% filter( visibility_node == input$Visibility_type) }
        trip_df <- trip_df %>% filter(as.Date(trip_df$raw_date, format = '%m/%d/%Y') >= input$Date_Slider[1])
        trip_df <- trip_df %>% filter(as.Date(trip_df$raw_date, format = '%m/%d/%Y') <= input$Date_Slider[2])
        
        
        if (nrow(trip_df) == 0) {showNotification('No Rows Returned Based On Settings', type = 'error', closeButton = FALSE)}
        
        validate(
            need(nrow(trip_df) != 0, '')
        )
        
        return(trip_df)
    }) # Master data for trips 
    Start_station_marker <- reactive({ 
        station_df <- df2
        s <- station_df[station_df$name == input$Station_Sel, ] 
        return(s)
    }) # Marker station data for leaflet
    End_station_markers <- reactive({
        s_df <- df2
        start_end_stations <- Trip_data() %>% count(start_station_name, end_station_name, sort = TRUE)
        start_end_stations <- start_end_stations %>% select(end_station_name, n)
        colnames(start_end_stations) <- c('name', 'weight')
        
        s_df <- inner_join(s_df, start_end_stations[], by = 'name') # Join the values together to get the weights
        return(s_df)
    })
    
    # Build UI elements
    output$Station_Sel_UI <- renderUI({
        selectInput(
            inputId = 'Station_Sel',
            label = 'Start Station',
            choices = sort(unique(df$start_station_name))
        )
    })
    output$Date_Slider_UI <- renderUI({
        sliderInput(
            inputId = 'Date_Slider', 
            label = 'Date Selection', 
            min = min(as.Date(df$raw_date, format = '%m/%d/%Y')),
            max = max(as.Date(df$raw_date, format = '%m/%d/%Y')),
            value = c(min(as.Date(df$raw_date, format = '%m/%d/%Y')), max(as.Date(df$raw_date, format = '%m/%d/%Y')))
        )
    })
    
    # Visnetwork Visualization 
    output$network_vis <- renderVisNetwork({
        start_end_stations <- Trip_data() %>% count(start_station_name, end_station_name, sort = TRUE)
        
        # Set up nodes
        nodes <- as.data.frame(unique(c(start_end_stations$start_station_name, start_end_stations$end_station_name)))
        nodes$id <- 1:length(nodes[, 1])
        colnames(nodes) <- c('name', 'id')
        nodes$font.color = 'White'
        
        
        # Set up edges
        edges <- start_end_stations
        colnames(edges) <- c('from', 'to', 'label')
        edges$length <- 400
        edges$arrows <- 'to'
        edges$width <- ((edges$label - min(edges$label)) / (max(edges$label) - min(edges$label))) * 10
        
        # Create graph
        routes_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE) # Create the graph in Igraph for ease of use
        routes_vis <- toVisNetworkData(routes_igraph) # Transform to Vis Network
        visNetwork(nodes = routes_vis$nodes, edges = routes_vis$edges) # Visualize 
        
    })
    
    # Leaflet Visualization
    output$leaflet_vis <- renderLeaflet({
        leaflet(width = 870, height = 700) %>% addTiles(urlTemplate = "//{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png") %>% 
            setView(lat=37.785, lng= -122.415253, 13)
    })
    
    # Leaflet modification observer
    observe({
        req(input$Station_Sel)
        
        # Add marker for selected station
        leafletProxy('leaflet_vis', data = Start_station_marker() ) %>%
            clearMarkers() %>%
            clearControls() %>%
            addMarkers(
                lng = ~long, 
                lat = ~lat, 
                label = ~name
            )
        
        # set up color palette for circle markers
        pal <- colorNumeric(
            palette = colorRampPalette(c('red', 'green'))(4), 
            domain = End_station_markers()$weight
        )
        
        # Set up labels for circle markers
        Labels <- sprintf(
                        '<strong>Station: </strong>%s <br>
                        <strong>Trips: </strong>%s <br>',
                        End_station_markers()$name, 
                        End_station_markers()$weight
        ) %>% lapply(HTML)
                        
                        
            
        leafletProxy('leaflet_vis', data = End_station_markers()) %>%
            addCircleMarkers(
                lng = ~long,
                lat = ~lat,
                radius = 4,
                fillOpacity = .85,
                stroke = FALSE,
                color = ~pal(weight),
                label = Labels
            )
    })
    
    
    # Data Table Test 
    output$testtable <- DT::renderDataTable(Trip_data())
    


})
