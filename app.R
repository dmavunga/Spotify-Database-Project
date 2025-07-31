# install.packages(c("httr", "jsonlite"))
# library(httr)
# library(jsonlite)
# 
# # Set your Supabase project info
# supabase_url <- "https://cwdngtgxdcpajvsnkmwt.supabase.co/rest/v1"
# supabase_key <- "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZG5ndGd4ZGNwYWp2c25rbXd0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzU0NTc3MCwiZXhwIjoyMDY5MTIxNzcwfQ.3foGFNYZ7stzqowjPG3KD5OSJHx4pDn3YEKR5PkJziU"
# 
# # Table you want to query
# table_name <- "artist"
# 
# # Build the request URL
# url <- paste0(supabase_url, "/", table_name, "?select=*")
# 
# # Make GET request with API key in headers
# res <- GET(url, add_headers(
#   apikey = supabase_key,
#   Authorization = paste("Bearer", supabase_key)
# ))
# 
# # Parse JSON content
# data <- content(res, "text", encoding = "UTF-8")
# df <- fromJSON(data)
# 
# print(df)
# 
# 
# library(rsconnect)
# 
# # Replace with your shinyapps.io account info from the dashboard
# rsconnect::setAccountInfo(name='dmavunga',
#                           token='8116AD2685BCBBA30BCE6445D1238D50',
#                           secret='P7p8DX8LtoFnGXcJpyYUw8q71upUAYg6D2sz0Rt0')
# 
# library(rsconnect)
# rsconnect::deployApp("C:\\Users\\rjkea\\OneDrive\\Documents\\Shiny\\Db Assignment v2")

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


# library(rsconnect)
# 
# # Replace with your shinyapps.io account info from the dashboard
# rsconnect::setAccountInfo(name='dmavunga',
#                           token='8116AD2685BCBBA30BCE6445D1238D50',
#                           secret='P7p8DX8LtoFnGXcJpyYUw8q71upUAYg6D2sz0Rt0')
# 
# library(rsconnect)
# rsconnect::deployApp("C:\\Users\\rjkea\\OneDrive\\Documents\\Shiny")