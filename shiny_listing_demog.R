# Load required libraries
# Function to install packages only if they are not already installed
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  } else {
    message(paste(package, "is already installed."))
  }
}

# List of packages to install
packages <- c("shiny", "dplyr", "haven", "DT")

# Install each package in the list
for (pkg in packages) {
  install_if_missing(pkg)
}

library(shiny)
library(dplyr)
library(DT)
library(haven)

# Define UI
ui <- fluidPage(
  titlePanel("ICH Listing of Demographic Characteristics"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload DM.xpt Dataset", 
                accept = c(".xpt")),
      actionButton("load", "Load Data"),
      
      # Filter Inputs
      checkboxGroupInput("age_filter", "Select Age Groups:",
                         choices = c("18-25", "26-35", "36-45", "46-55", "56-65", "66+")),
      checkboxGroupInput("sex_filter", "Select Sex:",
                         choices = c("Male", "Female")),
      checkboxGroupInput("race_filter", "Select Race:",
                         choices = c("White", "Black or African American", "Asian", 
                                     "Hispanic or Latino", "Other")),
      checkboxGroupInput("ethnic_filter", "Select Ethnic Group:",
                         choices = c("Hispanic or Latino", "Not Hispanic or Latino", "Unknown"))
    ),
    mainPanel(
      h3("Listing of Demographic Characteristics"),
      DTOutput("demographicsTable")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to read data when the button is pressed
  demographics_data <- reactiveVal()
  
  observeEvent(input$load, {
    req(input$file)
    # Read the uploaded .xpt file
    dem_data <- read_xpt(input$file$datapath)
    
    # Select relevant demographic variables and modify labels
    demographics_data(dem_data %>%
                        select(SUBJID, AGE, SEX, RACE, ETHNIC) %>%
                        mutate(
                          AGE = as.numeric(AGE), # Ensure AGE is numeric
                          SEX = factor(SEX, levels = c('M', 'F'), labels = c("Male", "Female")),
                          RACE = factor(RACE, labels = c("White", "Black or African American", "Asian", 
                                                         "Hispanic or Latino", "Other")),
                          ETHNIC = factor(ETHNIC, levels = c("Hispanic or Latino", "Not Hispanic or Latino", "Unknown"))
                        ))
  })
  
  # Reactive expression to filter data based on user inputs
  filtered_data <- reactive({
    req(demographics_data())
    
    data <- demographics_data()
    
    # Filter by age
    if (!is.null(input$age_filter) && length(input$age_filter) > 0) {
      age_ranges <- list(
        "18-25" = 18:25,
        "26-35" = 26:35,
        "36-45" = 36:45,
        "46-55" = 46:55,
        "56-65" = 56:65,
        "66+" = 66:100 # Assuming 100 as an upper limit for age filtering
      )
      selected_ages <- unlist(lapply(input$age_filter, function(x) age_ranges[[x]]))
      data <- data[data$AGE %in% selected_ages, ]
    }
    
    # Filter by sex
    if (!is.null(input$sex_filter) && length(input$sex_filter) > 0) {
      data <- data[data$SEX %in% input$sex_filter, ]
    }
    
    # Filter by race
    if (!is.null(input$race_filter) && length(input$race_filter) > 0) {
      data <- data[data$RACE %in% input$race_filter, ]
    }
    
    # Filter by ethnicity
    if (!is.null(input$ethnic_filter) && length(input$ethnic_filter) > 0) {
      data <- data[data$ETHNIC %in% input$ethnic_filter, ]
    }
    
    return(data)
  })
  
  # Render the demographic table
  output$demographicsTable <- renderDT({
    req(filtered_data())
    datatable(filtered_data(), options = list(pageLength = 10), rownames = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
