#install.packages(c("httr", "jsonlite"))
library(shiny)
library(httr)
library(jsonlite)

ui <- fluidPage(
  tableOutput("table")
)

server <- function(input, output, session) {
  supabase_url <- "https://cwdngtgxdcpajvsnkmwt.supabase.co/rest/v1"
  supabase_key <- "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZG5ndGd4ZGNwYWp2c25rbXd0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzU0NTc3MCwiZXhwIjoyMDY5MTIxNzcwfQ.3foGFNYZ7stzqowjPG3KD5OSJHx4pDn3YEKR5PkJziU"  # Use environment vars, don't hardcode in real app
  
  table_name <- "artist"
  url <- paste0(supabase_url, "/", table_name, "?select=*")
  
  res <- httr::GET(url, httr::add_headers(
    apikey = supabase_key,
    Authorization = paste("Bearer", supabase_key)
  ))
  
  data <- httr::content(res, "text", encoding = "UTF-8")
  df <- jsonlite::fromJSON(data)
  
  output$table <- renderTable({
    df
  })
}

shinyApp(ui, server)

#print(df)


library(rsconnect)


rsconnect::setAccountInfo(name='dmavunga',
                          token='8116AD2685BCBBA30BCE6445D1238D50',
                          secret='P7p8DX8LtoFnGXcJpyYUw8q71upUAYg6D2sz0Rt0')

library(rsconnect)
rsconnect::deployApp("C:\\Users\\rjkea\\OneDrive\\Documents\\Shiny")
