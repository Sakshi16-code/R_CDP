# Load required libraries and packages
required_packages <- c("dplyr", "haven")

# Function to install missing packages
install_missing_packages <- function(packages) {
  # Check for each package if it is installed
  for (package in packages) {
    if (!requireNamespace(package, quietly = TRUE)) {
      message(paste("Installing package:", package))
      install.packages(package)
    } else {
      message(paste("Package already installed:", package))
    }
  }
}

# Call the function with the list of required packages
install_missing_packages(required_packages)

library(dplyr)
library(haven)

# Set random seed for reproducibility
set.seed(123)

# Define the number of subjects
Total_N <- 320

# Create a data frame for countries and their codes
country_info <- data.frame(
  COUNTRY = c("United States", "Canada", "United Kingdom", "Germany", 
              "France", "Italy", "Australia", "Japan", "India", "Brazil"),
  COUNTRYCD = c("US", "CA", "GB", "DE", "FR", "IT", "AU", "JP", "IN", "BR")
)
# Create the DM dataset
dm_dataset <- data.frame(
  STUDYID = rep("STUDY01", Total_N),  # Study ID
  DOMAIN = rep("DM", Total_N),        # Domain
  SUBJID = sprintf("SUBJ%03d", 1:Total_N),   # Subject ID
  SEX = sample(c("M", "F"), Total_N, replace = TRUE), # Sex
  RACE = sample(c("White", "Black or African American", "Asian", "Hispanic or Latino", "Other"), Total_N, replace = TRUE), # Race
  AGE = sample(18:80, Total_N, replace = TRUE),  # Age
  AGEU = rep("YEARS", Total_N),                # Age Unit
  ARM = sample(c("Placebo", "Drug A", "Drug B"), Total_N, replace = TRUE)  # Treatment Arm
)

# Create the ARMCD variable after ARM is created
dm_dataset <- dm_dataset %>%
  mutate(
    ARMCD = case_when(
      ARM == "Placebo" ~ "PBO",
      ARM == "Drug A" ~ "DRA",
      ARM == "Drug B" ~ "DRB",
      TRUE ~ NA_character_  # Handle unexpected values
    ),
    COUNTRY = sample(country_info$COUNTRY, Total_N, replace = TRUE)  # Add COUNTRY variable
  )

# Derive USUBJID as specified
dm_dataset <- dm_dataset %>%
  mutate(
    USUBJID = paste0(trimws(STUDYID), "/", trimws(SUBJID))  # Concatenate STUDYID and SUBJID
  )

# Merge with country codes
dm_dataset <- dm_dataset %>%
  left_join(country_info, by = "COUNTRY") %>%
  rename(COUNTRYCD = COUNTRYCD)
# Print the first few rows of the dataset
print(head(dm_dataset))

# Create the output directory if it doesn't exist
output_dir <- "sdtm"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Export the dataset as XPT file to the new folder
output_file_path <- file.path(output_dir, "dm.xpt")
write_xpt(dm_dataset, output_file_path)

# Confirm the file creation
message(paste("Exported dm.xpt to:", output_file_path))
read_xpt("dm.xpt")
