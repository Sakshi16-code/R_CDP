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
packages <- c("shiny", "dplyr","haven", "DT")

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
      actionButton("load", "Load Data")
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
    
    # Select relevant demographic variables (modify according to your dataset)
    demographics_data(dem_data %>%
                        select(SUBJID, AGE, SEX, RACE, ETHNIC) %>%
                        mutate(AGE = as.numeric(AGE), # Ensure AGE is numeric
                               SEX = factor(SEX, levels = c('M', 'F'), labels = c("Male", "Female")),
                               RACE = factor(RACE, labels = c("White", "Black or African American", "Asian", "Other")),
                               ETHNIC = factor(ETHNIC, labels = c("Hispanic or Latino", "Not Hispanic or Latino"))))
  })
  
  # Render the demographic table
  output$demographicsTable <- renderDT({
    req(demographics_data())
    datatable(demographics_data(), options = list(pageLength = 10), rownames = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
