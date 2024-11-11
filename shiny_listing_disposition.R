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
  titlePanel("Discontinuation Data Filter"),
  sidebarLayout(
    sidebarPanel(
      fileInput("dm_file", "Upload DM Dataset (dm.xpt):", 
                accept = c(".xpt")),
      fileInput("ds_file", "Upload DS Dataset (ds.xpt):", 
                accept = c(".xpt")),
      actionButton("load", "Load Data"),
      
      # Filter Inputs
      uiOutput("reasons_ui")  # Dynamic UI for reasons
    ),
    mainPanel(
      h3("Filtered Discontinuation Data"),
      DTOutput("discontinuationTable")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to store datasets
  datasets <- reactiveVal()
  
  observeEvent(input$load, {
    req(input$dm_file, input$ds_file)  # Require that both files are uploaded
    dm <- read_xpt(input$dm_file$datapath)
    disposition_data <- read_xpt(input$ds_file$datapath) 
    
    # Convert blanks to NA only for character columns
    disposition_data[] <- lapply(disposition_data, function(col) {
      if (is.character(col)) {
        na_if(col, "")
      } else {
        col  # Return non-character columns unchanged
      }
    })
    
    # Merge datasets
    merged_dm_ds <- disposition_data %>%
      inner_join(dm %>% select(USUBJID, ACTARM), by = "USUBJID")
    
    # Create the discontinued list
    discontinued_list <- merged_dm_ds %>%
      filter(DSDECOD %in% c("ADVERSE EVENT", "LOST TO FOLLOW-UP", "PROTOCOL DEVIATION", "OTHER")) %>%
      select(USUBJID, ACTARM, DSDECOD) %>%
      rename(
        Subject_ID = USUBJID,
        Treatment = ACTARM,
        Reason_for_Discontinuation = DSDECOD
      )
    
    datasets(discontinued_list)  # Store the dataset
  })
  
  # Render the checkbox group for filtering reasons dynamically
  output$reasons_ui <- renderUI({
    req(datasets())  # Ensure datasets are available
    unique_reasons <- unique(datasets()$Reason_for_Discontinuation)
    checkboxGroupInput("reasons", "Select Discontinuation Reasons:",
                       choices = unique_reasons[unique_reasons != ""])  # Update choices, excluding empty
  })
  
  # Reactive expression to filter data based on user inputs
  filtered_data <- reactive({
    req(datasets())
    data <- datasets()
    
    if (!is.null(input$reasons) && length(input$reasons) > 0) {
      data <- data[data$Reason_for_Discontinuation %in% input$reasons, ]
    }
    
    return(data)
  })
  
  # Render the discontinuation table
  output$discontinuationTable <- renderDT({
    req(filtered_data())
    datatable(filtered_data(), options = list(pageLength = 10), rownames = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
