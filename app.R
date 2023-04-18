#Load libraries
library(tidyverse)
library(readxl)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(devtools)
library(rsconnect)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(ggthemes)
library(markdown)

#Import data
gdp_by_state <- read_excel("data/gdp_by_state.xlsx")
personal_income_state <- read_excel("data/personal_income_state.xlsx")
population_by_state <- read_excel("data/population_by_state.xlsx")
percap_income_by_state <- read_excel("data/percap_income_by_state.xlsx")

## Data Wrangling
# GDP data 
gdp <- gdp_by_state[-c(1)] #remove first column because it's not relevant 
gdp <- gdp %>% filter(rowSums(is.na(gdp)) != ncol(gdp)) #remove rows with all NA values
longer_gdp <- #pivot into longer format 
  gdp %>%
  pivot_longer(
    cols = 2:25,
    names_to = "year",
    values_to = "GDP")

# Population data
population <- population_by_state[-c(1)] #remove first column because it's not relevant
population[population == "(NA)"] <- NA #Problem: right now, NA is expressed as a character string. Convert into NA type instead. 

population <- population %>% # Use mutate to convert col types into a double 
  mutate(across(colnames(population)[2:25], as.double))

longer_population <- #pivot into longer format 
  population %>%
  pivot_longer(
    cols = 2:25,
    names_to = "year",
    values_to = "Population"
  ) 

#Income Data
income <- personal_income_state[-c(1)] #remove first column because it's not relevant 

income[income == "(NA)"] <- NA #Problem: right now, NA is expressed as a character string. Convert into NA type instead. 
income <- income %>% # Use mutate to convert col types into a double 
  mutate(across(colnames(income)[2:25], as.double))
longer_income <- #pivot into longer format 
  income %>%
  pivot_longer(
    cols = 2:25,
    names_to = "year",
    values_to = "income"
  ) 

#Per capita Income data
income_percap <- percap_income_by_state[-c(1)]
income_percap <- income_percap %>% # Use mutate to convert col types into a double 
  mutate(across(colnames(income_percap)[2:25], as.double))
longer_income_percap <- #pivot into longer format 
  income %>%
  pivot_longer(
    cols = 2:25,
    names_to = "year",
    values_to = "perCapIncome"
  ) 


#Combine datasets using inner-join statements 
merged_data1 <- inner_join(longer_gdp, longer_population, by = c("GeoName", "year")) 
merged_data2 <-inner_join(longer_income, longer_income_percap, by = c("GeoName", "year")) 
merged_data <- inner_join(merged_data1, merged_data2, by = c("GeoName", "year"))

#Add a calculated column for GDP per capita 
merged_data <- mutate(merged_data, perCapGDP = GDP/Population * 1000000)



#Shiny App
app_data <- merged_data


# Define User Interface
ui <- fluidPage(theme = shinytheme("sandstone"),
                navbarPage("Comparing Regional Differences in Economic Growth",
                           tabPanel("Tool",
                                    sidebarLayout(position = "left",
                                         sidebarPanel(
                                           radioButtons("indicator",
                                                        label = h4("Choose Indicator:"),
                                                        choices = c("Gross Domestic Product (GDP)" = "GDP",
                                                                    "GDP per capita" = "perCapGDP",
                                                                    "Aggregate Personal Income" = "income",
                                                                    "Personal Income per capita" = "perCapIncome"),
                                                        selected = "GDP"),
                                           
                                           selectInput(inputId = "region1",
                                                       label = "Region 1",
                                                       choices = app_data$GeoName, 
                                                       selected = "Alabama"), 
                                           
                                           selectInput(inputId = "region2",
                                                       label = "Region 2",
                                                       choices = app_data$GeoName, 
                                                       selected = "Wyoming"),
                                           
                                           
                                           sliderInput("year_range",
                                                       label = "Year Range:",
                                                       min = 1998,
                                                       max = 2021,
                                                       value = c(2003, 2011), #default slider input when you first load the page 
                                                       step = 1)
                                         ),
                                         
                                         
                                         mainPanel(h3(textOutput("heading")),
                                                   plotOutput("plot"),
                                         )
                           )), 
                           
                           tabPanel("About",
                                    includeMarkdown("about.md")),
                           tabPanel("Data",
                                    includeMarkdown("references.md")),
                           selected = "Tool"))
          
                
# Define server 
server <- (function(input, output) {
  # Reactive heading for the graphic
  output$heading <- renderText({
    paste(input$region1, "and",
          input$region2, ",",
          min(input$year_range), "-", max(input$year_range)) })
  
  # Reactive Plot 
  plot_data <- reactive({
    
    if(is.null(input$region1)){
      return(NULL)
    }
    
    if(is.null(input$region2)){
      return(NULL)
    }
    
    
    app_data %>%
      select(GeoName, year, 
             matches(input$indicator)) %>%
      filter(GeoName %in% c(input$region1, 
                            input$region2),
             year >= min(input$year_range) &
               year <= max(input$year_range))
  })
  
  
  
  
  # Render ggplot plot based on variable input from radioButtons
  output$plot <- renderPlot({
    
    if(is.null(plot_data()$year)){
      return(NULL)
    }
    
    #change y-axis labels based on user input 
    if(input$indicator == "GDP") y_axis_label <- "GDP (in millions USD)"
    if(input$indicator == "perCapGDP") y_axis_label <- "GDP per capita (in USD)"
    if(input$indicator == "income") y_axis_label <- "Real Personal Income (in millions USD)"
    if(input$indicator == "perCapIncome") y_axis_label <- "Real Personal Income per capita (in USD)"
    


    
    ggplot(data = plot_data(), mapping = aes_string(x = "year", y = input$indicator, color = "GeoName")) +
      geom_point() + 
      geom_line(aes(group = GeoName)) + 
      labs(color = "Region") + 
      xlab("Year") +
      ylab(y_axis_label) + 
      theme_economist() + #use the Economist theme

      theme(
        legend.title=element_blank(), #remove legend title
        axis.line = element_line(colour = "black"),
        axis.title.x = element_text(margin = unit(c(3, 0, 0, 0), "mm")),
        
        axis.title.y = element_text(margin = unit(c(0, 3, 0, 0), "mm"), angle = 90)

      )

    
  
  })
  
  
  
})


# Run the application 
shinyApp(ui = ui, server = server)




