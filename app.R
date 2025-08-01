
library(shiny)
library(httr)
library(jsonlite)
library(DT)
library(ggplot2)
library(plotly)

# ---------- Supabase Config ----------
supabase_url <- "https://cwdngtgxdcpajvsnkmwt.supabase.co/rest/v1"
supabase_key <- "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZG5ndGd4ZGNwYWp2c25rbXd0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzU0NTc3MCwiZXhwIjoyMDY5MTIxNzcwfQ.3foGFNYZ7stzqowjPG3KD5OSJHx4pDn3YEKR5PkJziU"  # Replace with Sys.getenv("SUPABASE_KEY") for security

headers <- add_headers(
  apikey = supabase_key,
  Authorization = paste("Bearer", supabase_key),
  `Content-Type` = "application/json",
  Range = "0-999999"  # <-- Added here to remove 1,000 row limit
)

# ---------- Reusable Data Fetcher ----------
fetch_data <- function(table_name) {
  url <- paste0(supabase_url, "/", table_name, "?select=*")
  res <- GET(url, headers)
  fromJSON(content(res, "text", encoding = "UTF-8"))
}

ui <- navbarPage("Music DB Manager",
                 
                 # CREATE Tab
                 tabPanel("Add Data",
                          sidebarLayout(
                            sidebarPanel(
                              h4("Add Artist"),
                              textInput("artist_name", "Artist Name"),
                              actionButton("add_artist", "Add Artist"),
                              
                              hr(), h4("Add Album"),
                              textInput("album_name", "Album Name"),
                              textInput("album_artist", "Artist Name (must exist)"),
                              actionButton("add_album", "Add Album"),
                              
                              hr(), h4("Add Track"),
                              textInput("track_id", "Track ID"),
                              textInput("track_name", "Track Name"),
                              numericInput("duration", "Duration (ms)", 210000),
                              textInput("genre", "Genre"),
                              numericInput("popularity", "Popularity", 50),
                              checkboxInput("is_explicit", "Explicit?", FALSE),
                              textInput("track_album", "Album Name"),
                              textInput("track_artist", "Artist Name"),
                              actionButton("add_track", "Add Track"),
                              
                              hr(), h4("Add Track Details"),
                              numericInput("tempo", "Tempo", 120),
                              numericInput("danceability", "Danceability", 0.5),
                              numericInput("energy", "Energy", 0.5),
                              numericInput("loudness", "Loudness", -5),
                              numericInput("track_key", "Key", 5),
                              numericInput("track_mode", "Mode", 1),
                              numericInput("time_signature", "Time Signature", 4),
                              numericInput("speechiness", "Speechiness", 0.05),
                              numericInput("acousticness", "Acousticness", 0.3),
                              numericInput("instrumentalness", "Instrumentalness", 0.0),
                              numericInput("liveness", "Liveness", 0.2),
                              numericInput("valence", "Valence", 0.9),
                              actionButton("add_details", "Add Track Details")
                            ),
                            mainPanel(h4("Use the sidebar to add data"))
                          )
                 ),
                 
                 # READ Tab
                 tabPanel("View Data",
                          fluidRow(
                            column(6, h4("Artists"), dataTableOutput("view_artists")),
                            column(6, h4("Albums"), dataTableOutput("view_albums"))
                          ),
                          fluidRow(
                            column(6, h4("Tracks"), dataTableOutput("view_tracks")),
                            column(6, h4("Track Details"), dataTableOutput("view_details"))
                          )
                 ),
                 
                 # UPDATE Tab
                 tabPanel("Update Data",
                          sidebarLayout(
                            sidebarPanel(
                              textInput("update_track_id", "Track ID"),
                              numericInput("new_popularity", "New Popularity", 80),
                              actionButton("update_popularity", "Update Popularity"),
                              checkboxInput("mark_explicit", "Mark as Explicit"),
                              actionButton("update_explicit", "Update Explicit Flag")
                            ),
                            mainPanel(h4("Use the sidebar to update track data"))
                          )
                 ),
                 
                 # DELETE Tab
                 tabPanel("Delete Data",
                          sidebarLayout(
                            sidebarPanel(
                              textInput("delete_track_id", "Track ID"),
                              actionButton("delete_details", "Delete Track Details"),
                              actionButton("delete_track", "Delete Track"),
                              
                              hr(),
                              textInput("delete_album", "Album Name"),
                              actionButton("delete_album_btn", "Delete Album"),
                              
                              hr(),
                              textInput("delete_artist", "Artist Name"),
                              actionButton("delete_artist_btn", "Delete Artist")
                            ),
                            mainPanel(h4("Use the sidebar to delete data"))
                          )
                 ),
                 
                 # VISUALIZE Tab
                 tabPanel("Visualizations",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput("plot_type", "Choose a Plot:",
                                          choices = c("Popularity by Genre", "Tempo Distribution")
                              ),
                              actionButton("generate_plot", "Generate Plot")
                            ),
                            mainPanel(plotlyOutput("track_plot"))
                          )
                 )
)

# ---------- SERVER ----------
server <- function(input, output, session) {
  
  # View: Populate DataTables with no 1,000 row limit
  output$view_artists <- renderDataTable({ fetch_data("artist") })
  output$view_albums <- renderDataTable({ fetch_data("album") })
  output$view_tracks <- renderDataTable({ fetch_data("track") })
  output$view_details <- renderDataTable({ fetch_data("track_details") })
  
  # Create: Artist
  observeEvent(input$add_artist, {
    body <- toJSON(list(artist_name = input$artist_name), auto_unbox = TRUE)
    res <- POST(paste0(supabase_url, "/artist"), headers, body = body)
    
    if (status_code(res) != 201) {
      showNotification("Failed to add artist", type = "error")
    } else {
      showNotification("Artist added successfully!", type = "message")
    }
  })
  
  # Create: Album
  observeEvent(input$add_album, {
    query <- paste0("artist?select=artist_id&artist_name=eq.", URLencode(input$album_artist))
    res <- GET(paste0(supabase_url, "/", query), headers)
    artist_id <- fromJSON(content(res, "text"))$artist_id
    if (length(artist_id)) {
      body <- toJSON(list(album_name = input$album_name, artist_id = artist_id), auto_unbox = TRUE)
      res <- POST(paste0(supabase_url, "/album"), headers, body = body)
      if (status_code(res) != 201) {
        showNotification("Failed to add album", type = "error")
      } else {
        showNotification("Album added successfully!", type = "message")
      }
    } else {
      showNotification("Artist not found for album", type = "error")
    }
  })
  
  # Create: Track
  observeEvent(input$add_track, {
    artist_q <- paste0("artist?select=artist_id&artist_name=eq.", URLencode(input$track_artist))
    album_q <- paste0("album?select=album_id&album_name=eq.", URLencode(input$track_album))
    artist_id <- fromJSON(content(GET(paste0(supabase_url, "/", artist_q), headers), "text"))$artist_id
    album_id <- fromJSON(content(GET(paste0(supabase_url, "/", album_q), headers), "text"))$album_id
    if (length(artist_id) && length(album_id)) {
      body <- toJSON(list(
        track_id = input$track_id,
        track_name = input$track_name,
        duration = input$duration,
        genre = input$genre,
        popularity = input$popularity,
        is_explicit = tolower(as.character(input$is_explicit)),
        album_id = album_id,
        artist_id = artist_id
      ), auto_unbox = TRUE)
      res <- POST(paste0(supabase_url, "/track"), headers, body = body)
      if (status_code(res) != 201) {
        showNotification("Failed to add track", type = "error")
      } else {
        showNotification("Track added successfully!", type = "message")
      }
    } else {
      showNotification("Artist or Album not found for track", type = "error")
    }
  })
  
  # Create: Track Details
  observeEvent(input$add_details, {
    body <- toJSON(list(
      track_id = input$track_id,
      tempo = input$tempo,
      danceability = input$danceability,
      energy = input$energy,
      loudness = input$loudness,
      track_key = input$track_key,
      track_mode = input$track_mode,
      time_signature = input$time_signature,
      speechiness = input$speechiness,
      acousticness = input$acousticness,
      instrumentalness = input$instrumentalness,
      liveness = input$liveness,
      valence = input$valence
    ), auto_unbox = TRUE)
    res <- POST(paste0(supabase_url, "/track_details"), headers, body = body)
    if (status_code(res) != 201) {
      showNotification("Failed to add track details", type = "error")
    } else {
      showNotification("Track details added successfully!", type = "message")
    }
    
  })
  
  observeEvent(input$delete_artist_btn, {
    artist_name <- input$delete_artist
    
    if (artist_name == "") {
      showNotification("Please enter an artist name to delete.", type = "error")
      return()
    }
    
    # Delete URL with filter for artist_name (URL-encoded)
    url <- paste0(supabase_url, "/artist?artist_name=eq.", URLencode(artist_name))
    
    # Send DELETE request
    res <- DELETE(url, headers)
    
    if (status_code(res) == 204) {
      showNotification(paste("Artist", artist_name, "deleted successfully!"), type = "message")
    } else if (status_code(res) == 404) {
      showNotification("Artist not found.", type = "error")
    } else {
      showNotification(paste("Failed to delete artist: HTTP", status_code(res)), type = "error")
    }
    
  })
  
  observeEvent(input$update_popularity, {
    track_id <- input$update_track_id
    new_pop <- input$new_popularity
    
    if (track_id == "") {
      showNotification("Please enter a Track ID to update.", type = "error")
      return()
    }
    
    # Prepare the PATCH body
    body <- toJSON(list(popularity = new_pop), auto_unbox = TRUE)
    
    # Supabase PATCH URL with filter on track_id (exact match)
    url <- paste0(supabase_url, "/track?track_id=eq.", URLencode(track_id))
    
    # Send PATCH request
    res <- PATCH(url, headers, body = body)
    
    if (status_code(res) == 204) {
      showNotification(paste("Popularity for Track ID", track_id, "updated successfully!"), type = "message")
    } else if (status_code(res) == 404) {
      showNotification("Track not found.", type = "error")
    } else {
      showNotification(paste("Failed to update popularity: HTTP", status_code(res)), type = "error")
    }
  })
  
  #Vizualization plots
  
  observeEvent(input$generate_plot, {
    
    if (input$plot_type == "Popularity by Genre") {
      tracks <- fetch_data("track")
      genre_summary <- aggregate(popularity ~ genre, data = tracks, FUN = mean)
      genre_summary <- genre_summary[order(-genre_summary$popularity), ]
      genre_summary <- head(genre_summary, 30)
      
      output$track_plot <- renderPlotly({
        gg <- ggplot(genre_summary, aes(x = reorder(genre, popularity), y = popularity)) +
          geom_col(fill = "#3182bd") +
          coord_flip() +
          labs(title = "Average Popularity by Genre", x = "Genre", y = "Popularity") +
          theme_minimal()
        ggplotly(gg)
      })
      
    } else if (input$plot_type == "Tempo Distribution") {
      details <- fetch_data("track_details")
      
      output$track_plot <- renderPlotly({
        gg <- ggplot(details, aes(x = tempo)) +
          geom_histogram(binwidth = 5, fill = "#de2d26", color = "white") +
          labs(title = "Tempo Distribution", x = "Tempo (BPM)", y = "Count") +
          theme_minimal()
        ggplotly(gg)
      })
    }
  })
}
# ---------- Run App ----------
shinyApp(ui, server)


#print(df)


# library(rsconnect)
# 
# # Replace with your shinyapps.io account info from the dashboard
# rsconnect::setAccountInfo(name='dmavunga',
#                           token='8116AD2685BCBBA30BCE6445D1238D50',
#                           secret='P7p8DX8LtoFnGXcJpyYUw8q71upUAYg6D2sz0Rt0')
# 
# rsconnect::deployApp("C:\\Users\\rjkea\\OneDrive\\Documents\\Shiny") 

