#????????????????????
library(shiny)
library(climate)
library(shinythemes)
library(dplyr)
library(plotly)
library(writexl)

ui <- fluidPage(theme = shinytheme("readable"),
    navbarPage(
      theme = "readable",  
      "CLIMATE APP",
      tabPanel("1",
               # Page header
               headerPanel('Daily Temperature'),
               
               # Input values
               sidebarPanel(
                 HTML("<h3>Input parameters</h3>"),
                 
                 selectInput("station", label = "Station:", 
                             #?????????? ???????????? ??????????????
                             choices = list("Nikolaevskoe" = "26167", "Novgorod" = "26179", "St.petersburg (Voejkovo)" = "26063"), 
                             selected = "Novgorod"),
                 dateInput("date1", "Date:", value = "2022-02-21"),
                 dateInput("date2", "Date:", value = "2022-03-21"),
                 
                 actionButton("submitbutton", "Submit", class = "btn btn-primary")
               ),
               
               mainPanel(
                 tags$label(h3('Output')), 
                 plotlyOutput("distPlot"),
                 tableOutput('datasetInput')
                 
               )
               
      ), # Navbar 1, tabPanel
      tabPanel("2",
               # Page header
               headerPanel('Daily Temperature'),
               
               # Input values
               sidebarPanel(
                 HTML("<h3>Input parameters</h3>"),
                 
                 #selectInput("station", label = "Station:", 
                             #?????????? ???????????? ??????????????
                             #choices = list("Nikolaevskoe" = "26167", "Novgorod" = "26179", "St.petersburg (Voejkovo)" = "26063"), 
                             #selected = "Novgorod"),
                 #dateInput("date1", "Date:", value = "2022-02-21"),
                 #("date2", "Date:", value = "2022-03-21"),
                 
                 #actionButton("submitbutton", "Submit", class = "btn btn-primary")
               ),
               
               mainPanel(
                 
               )
               
      ), # Navbar 1, tabPanel
      tabPanel("3", "This panel is intentionally left blank")
      
    ) # navbarPage            
    
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
 
  # Plot1
  output$distPlot <- renderPlotly({
    
    dfff <- data.frame(
      Name = c("station",
               "date1",
               "date2"),
      Value = as.character(c(input$station,
                             input$date1,
                             input$date2)),
      stringsAsFactors = FALSE)
    
    df = meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station)
    
    data1 <- data.frame(df[3], df[2])
    fig1 <- plot_ly(data1, x = ~ Date, y = ~ TemperatureCAvg) %>% 
      add_lines()
    fig1
    
  })
  
  
  # Data Table
  output$datasetInput <- renderTable({  
    
    dfff <- data.frame(
      Name = c("station",
               "date1",
               "date2"),
      Value = as.character(c(input$station,
                             input$date1,
                             input$date2)),
      stringsAsFactors = FALSE)
    
    df = meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station)
    
    df1 = df[2]
    
    data.frame(format(df1, format = "%d %m %Y"), df[3:5])
    
    #write_xlsx(df[2:5], 'D:\\data.xlsx')
    
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
