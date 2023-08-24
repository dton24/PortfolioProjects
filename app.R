#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Load libraries
library(shiny)
library(shinydashboard)
library(lubridate)
library(ggplot2)
library(readr)

# turn-off scientific notation like 1e+48
options(scipen=999)  

# Defining the dataset
superbowl_ads <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-03-02/youtube.csv')
superbowl_ads$published_at <- ymd_hms(superbowl_ads$published_at)

# Define UI
ui <- dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Superbowl Ads Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Line Chart", tabName = "linechart", badgeColor = "blue", icon = icon("line-chart")),
      menuItem("Scatterplot", tabName = "scatterplot",  badgeColor = "red", icon = icon("area-chart")),
      menuItem("Bar Chart", tabName = "barchart",  badgeColor = "green", icon = icon("bar-chart"))
    )
  ),
  dashboardBody(
    tabItems(
      # Line Chart
      tabItem(tabName = "linechart",
              fluidRow(
                column(4, selectInput(inputId = "y_variable", label = "Select Y-axis Variable", choices = c("view_count", "like_count", "dislike_count", "comment_count"), selected = "view_count"))
              ),
              fluidRow(
                box(plotOutput("linePlot"), width = 12)
              )
      ),
      # Scatterplot
      tabItem(tabName = "scatterplot", 
              fluidRow(
                box(plotOutput("scatterPlot"), width = 12)
              ),
              fluidRow(
                box(title = "Choose your variables", width = 12,
                    selectInput(inputId = "x_variable", label = "Select variable for x-axis", choices = c("like_count", "dislike_count"), selected = "like_count"),
                    selectInput(inputId = "y_variable", label = "Select variable for y-axis", choices = c("like_count","dislike_count"), selected = "dislike_count"))
              )
      ),
      # Bar chart
      tabItem(tabName = "barchart",
              fluidRow(
                box(plotOutput("barChart"), width = 12),
                box(title = "Choose your variables", 
                    selectInput(inputId = "line_variable", label = "Select variable for bar chart", choices = c("view_count", "like_count", "dislike_count", "comment_count"), selected = "view_count"),
                    sliderInput(inputId = "year_range", label = "Select range of years:", min = min(superbowl_ads$year), max = max(superbowl_ads$year), 
                                value = c(min(superbowl_ads$year), max(superbowl_ads$year))))
              )
      )
    )
  )
)

# Define Server
server <- function(input, output) {
  
  # Line chart
  output$linePlot <- renderPlot({
    avg_data <- superbowl_ads %>%
      group_by(year = year(published_at)) %>%
      summarise(avg_value = mean(get(input$y_variable), na.rm = TRUE))
    
    ggplot(avg_data, aes(x = year, y = avg_value)) +
      geom_line(color = "#0072B2", size = 1.5, alpha = 0.8) +
      labs(
        title = paste("Line Plot"),
        x = "Year",
        y = paste("Average", sub("_count", "", input$y_variable), "s") # Fixed here
      ) +
      
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 22, face = "bold", margin = margin(b = 10)),
        axis.title.x = element_text(size = 18, face = "bold", margin = margin(t = 10)),
        axis.title.y = element_text(size = 18, face = "bold", margin = margin(r = 10)),
        axis.text.x = element_text(size = 14), 
        axis.text.y = element_text(size = 14),
        panel.grid.major.x = element_line(color = "grey85", size = 0.5),
        panel.grid.major.y = element_line(color = "grey85", size = 0.5)
      )
  })
  
  
  # Scatter plot
  output$scatterPlot <- renderPlot({
    
    # Remove any missing values from the selected columns
    data <- na.omit(superbowl_ads[,c(input$x_variable, input$y_variable)])
    
    # Base ggplot with dynamic x and y axis
    base_plot <- ggplot(data, aes_string(x = input$x_variable, y = input$y_variable))
    
    # Define the scatter plot layer with custom aesthetics
    scatter_layer <- geom_point(
      color = "#0072B2", 
      size = 2.5,
      alpha = 0.7
    )
    
    # Add a linear regression smooth line with confidence interval
    smooth_layer <- geom_smooth(
      method = 'lm',
      color = "red",
      fill = "pink",
      formula = y ~ x,           # specify the formula explicitly
      se = TRUE                  # Show the confidence interval shade
    )
    
    # Custom advanced theme
    custom_theme <- theme(
      plot.title = element_text(hjust = 0.5, size = 22, face = "bold", margin = margin(b = 10)),
      axis.title.x = element_text(size = 18, face = "bold", margin = margin(t = 10)),
      axis.title.y = element_text(size = 18, face = "bold", margin = margin(r = 10)),
      axis.text = element_text(size = 14),
      panel.background = element_rect(fill = "grey90"),
      panel.grid.major = element_line(color = "grey85"),
      panel.grid.minor = element_blank(),
      legend.position = "top",
      legend.text = element_text(size = 14),
      legend.title = element_text(size = 16, face = "bold")
    )
    
    # Combine and return the full plot
    base_plot +
      scatter_layer +
      smooth_layer +
      labs(title = paste("Relationship between Likes and Dislikes"),
           x = input$x_variable,
           y = input$y_variable) +
      theme_minimal() +         # Start with a minimal theme
      custom_theme              # Add custom modifications on top
  })
  
  # Bar chart
  output$barChart <- renderPlot({
    data <- na.omit(superbowl_ads[,c(input$line_variable, "year")])
    
    # Subset the data for the selected year range
    mask <- data$year >= input$year_range[1] & data$year <= input$year_range[2]
    filtered_data <- data[mask,]
    
    # Aggregation to ensure there's one value per year
    library(dplyr)
    aggregated_data <- filtered_data %>% 
      group_by(year) %>% 
      summarise(value = sum(get(input$line_variable))) 
    
    # Base ggplot with dynamic x and y axis
    base_plot <- ggplot(aggregated_data, aes(x = year, y = value, fill = value))
    
    # Define the bar chart layer
    bar_layer <- geom_bar(stat = "identity", position = "dodge")
    
    # Gradient fill based on aggregated values
    gradient_fill <- scale_fill_gradient(low = "lightblue", high = "blue", 
                                         breaks = c(min(aggregated_data$value), 
                                                    max(aggregated_data$value)),
                                         labels = scales::comma) 
    

    # Custom advanced theme
    custom_theme <- theme(
      plot.title = element_text(hjust = 0.5, size = 22, face = "bold", margin = margin(b = 10)),
      axis.title.x = element_text(size = 18, face = "bold", margin = margin(t = 10)),
      axis.title.y = element_text(size = 18, face = "bold", margin = margin(r = 10)),
      axis.text = element_text(size = 14),
      panel.background = element_rect(fill = "grey90"),
      panel.grid.major = element_line(color = "grey85"),
      panel.grid.minor = element_blank(),
      legend.position = "right",
      legend.text = element_text(size = 8),
      legend.direction = "vertical", # make the legend vertical
      legend.box = "vertical"
    )
    
    
    # Combine and return the full plot
    base_plot +
      bar_layer +
      gradient_fill +
      labs(
        title = paste("Bar Chart"),
        x = "Year",
        y = paste("Total", sub("_count", "", input$line_variable), "Count"), # NOTE: I changed input$y_variable to input$line_variable as that seems to be what you're using for barChart
        fill = input$line_variable  # Add this line to specify the legend title
      ) +
      theme_minimal() +         
      custom_theme
  })
  
  
}

shinyApp(ui, server)