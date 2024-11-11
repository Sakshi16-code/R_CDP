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

# Load necessary libraries
library(shiny)
library(haven) # for reading .xpt files
library(dplyr) # for data manipulation
library(DT) # for rendering data tables

ui <- fluidPage(
  titlePanel("ICH Listing of Age Ranges"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload DM.xpt Dataset", accept = c(".xpt")),
      actionButton("load", "Load Data"),
      hr(),
      h4("Filter Options"),
      selectInput("sexFilter", "Select Gender:", choices = NULL, multiple = TRUE),
      selectInput("raceFilter", "Select Race:", choices = NULL, multiple = TRUE),
      selectInput("ethnicFilter", "Select Ethnicity:", choices = NULL, multiple = TRUE)
    ),
    mainPanel(
      h3("Listing of Age Ranges as per CDISC Standards"),
      DTOutput("ageRangeTable")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to hold the dataset with filters applied
  original_data <- reactiveVal()
  filtered_data <- reactiveVal()
  
  observeEvent(input$load, {
    req(input$file)
    
    # Read and process the uploaded .xpt file
    dm_data <- read_xpt(input$file$datapath) %>%
      mutate(AGE = as.numeric(AGE)) %>% # Ensure AGE is numeric
      filter(!is.na(AGE)) # Remove rows where AGE is NA
    
    # Populate filter options based on the unique values in the dataset
    updateSelectInput(session, "sexFilter", choices = unique(dm_data$SEX), selected = unique(dm_data$SEX))
    updateSelectInput(session, "raceFilter", choices = unique(dm_data$RACE), selected = unique(dm_data$RACE))
    updateSelectInput(session, "ethnicFilter", choices = unique(dm_data$ETHNIC), selected = unique(dm_data$ETHNIC))
    
    # Store the dataset for further use
    original_data(dm_data)
    filtered_data(dm_data)
  })
  
  # Observe the filter selections and apply them to the data
  observeEvent({
    input$sexFilter
    input$raceFilter
    input$ethnicFilter
  }, {
    req(original_data())
    
    # Apply the selected filters to the original data
    filtered <- original_data() %>%
      filter(
        if (length(input$sexFilter) > 0) SEX %in% input$sexFilter else TRUE,
        if (length(input$raceFilter) > 0) RACE %in% input$raceFilter else TRUE,
        if (length(input$ethnicFilter) > 0) ETHNIC %in% input$ethnicFilter else TRUE
      ) %>%
      mutate(
        Age_Range = case_when(
          AGE < 18 ~ "<18",
          AGE >= 18 & AGE < 30 ~ "18-29",
          AGE >= 30 & AGE < 40 ~ "30-39",
          AGE >= 40 & AGE < 50 ~ "40-49",
          AGE >= 50 & AGE < 65 ~ "50-64",
          AGE >= 65 ~ "≥65",
          TRUE ~ "Unknown"
        )
      ) %>%
      group_by(Age_Range) %>%
      summarise(Count = n(), .groups = 'drop')
    
    # Update the reactive value with the filtered and grouped data
    filtered_data(filtered)
  })
  
  # Render the age range table
  output$ageRangeTable <- renderDT({
    req(filtered_data())
    datatable(filtered_data(), options = list(pageLength = 10), rownames = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)