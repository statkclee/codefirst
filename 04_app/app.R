#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(timetk)
library(reactable)
library(plotly)
library(pins)
library(shinythemes)


board_register_rsconnect(name="rsconnect", server="https://colorado.rstudio.com/rsc/", key = Sys.getenv("rsc-api"))
monthly_sales <- pin_get(name = "nick/monthly-sales", board = "rsconnect")
sales_by_returning <- pin_get(name = "nick/sales-by-returning", board = "rsconnect")

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("spacelab"),
                
                # Application title
                titlePanel("Sales Report"),
                
                # Sidebar with a slider input for number of bins 
                sidebarLayout(
                    sidebarPanel(
                        selectInput(inputId = "region",
                                    label = "Global Sales Region",
                                    choices = c("North America", "Latin America", "EMEA", "APAC"),
                                    selected = c("North America"),
                                    selectize = TRUE,
                                    multiple = FALSE),
                        dateRangeInput(inputId = "date",
                                       label = "Start and End Dates:",
                                       start = as.Date("2018-01-01"),
                                       end = Sys.Date()),
                        numericInput("alpha",
                                     "Anomaly sensitivity",
                                     min = .01, 
                                     max = .5, 
                                     step = .01,
                                     value = .2)
                    ),
                    
                    # Show a plot of the generated distribution
                    mainPanel(
                        tabsetPanel(type = "pills",
                                    tabPanel("Chart",
                                             plotlyOutput("salesPlot")),
                                    tabPanel("Anomalies",
                                             plotlyOutput("anomalyPlot")),
                                    tabPanel("Data",
                                             reactableOutput("dataTable")),
                                    tabPanel("Profit",
                                             plotOutput("profitPlot")))
                        
                    )
                )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    monthly_sales_filtered <-reactive({
        monthly_sales %>% 
            filter(region == input$region) %>% 
            filter_by_time(date, input$date[1], input$date[2])
    }) 
    
    
    output$salesPlot <- renderPlotly({
        monthly_sales_filtered() %>% 
            ungroup() %>% 
            plot_time_series(date, sales, .color_var = model, .smooth = FALSE, .interactive = TRUE,
                             .title = paste0("Monthly Sales by Model - ", input$region),
                             .color_lab = "Model")
    })
    
    output$anomalyPlot <- renderPlotly({
        monthly_sales_filtered() %>% 
            plot_anomaly_diagnostics(date, sales, .alpha = input$alpha)
    })
    
    output$dataTable <- renderReactable({
        monthly_sales_filtered() %>% 
            reactable(resizable = TRUE,
                      filterable = TRUE,
                      searchable = TRUE)
    })
    
    output$profitPlot <- renderPlot({
        sales <- read_csv("../sales.csv") %>% 
            mutate(net = price - cost - shipping) %>% 
            filter(region == input$region) %>% 
            filter_by_time(date, input$date[1], input$date[2])
        
        ggplot(sales, aes(x = model, y = net, color = model)) +
            geom_jitter(alpha = .25) +
            geom_point(stat = "summary", size = 5) +
            theme_minimal() +
            theme(legend.position = "none") +
            labs(title = "Profit by Model",
                 x = "Model",
                 y = "Profit")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
