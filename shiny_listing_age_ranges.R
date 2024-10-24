install_i_missing <- function(package) {
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
# Load necessary libraries
library(shiny)
library(haven) # for reading .xpt files
library(dplyr) # for data manipulation
library(DT) # for rendering data tables

# Define UI
ui <- fluidPage(
  titlePanel("ICH Listing of Age Ranges"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload DM.xpt Dataset", 
                accept = c(".xpt")),
      actionButton("load", "Load Data")
    ),
    mainPanel(
      h3("Listing of Age Ranges as per CDISC Standards"),
      DTOutput("ageRangeTable")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to read data when the button is pressed
  age_data <- reactiveVal()
  
  observeEvent(input$load, {
    req(input$file)
    # Read the uploaded .xpt file
    dm_data <- read_xpt(input$file$datapath)
    
    # Ensure AGE is numeric
    dm_data <- dm_data %>%
      mutate(AGE = as.numeric(AGE)) %>%
      filter(!is.na(AGE)) # Remove any rows where AGE is NA
    
    # Create age ranges
    age_data(dm_data %>%
               mutate(Age_Range = case_when(
                 AGE < 18 ~ "<18",
                 AGE >= 18 & AGE < 30 ~ "18-29",
                 AGE >= 30 & AGE < 40 ~ "30-39",
                 AGE >= 40 & AGE < 50 ~ "40-49",
                 AGE >= 50 & AGE < 65 ~ "50-64",
                 AGE >= 65 ~ "≥65",
                 TRUE ~ "Unknown"
               )) %>%
               group_by(Age_Range) %>%
               summarise(Count = n(), .groups = 'drop'))
  })
  
  # Render the age range table
  output$ageRangeTable <- renderDT({
    req(age_data())
    datatable(age_data(), options = list(pageLength = 10), rownames = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)