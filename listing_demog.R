#listing of demographic characteristics
library(dplyr)
library(officer)
library(admiral)
dm <- read_xpt("dm.xpt") %>% convert_blanks_to_na()
# Update SEX column to use "Female" and "Male" instead of "F" and "M"
dm <- dm %>%
  mutate(SEX = recode(SEX, `F` = "Female", `M` = "Male"))
# Calculate total count
total_count <- nrow(dm)
age_summary <- summary(dm$AGE) # Calculating summary statistics for Age
sex_table <- table(dm$SEX) # Creating frequency table for Sex
treatment_table <- table(dm$ACTARM) # Creating frequency table for Treatment
ethnicity_table <- table(dm$ETHNIC) # Creating frequency table for Ethnicity

#creating dataframe for the listing
lst_demo <- data.frame(
  Characteristic = c(
                    "N",
                    "Mean Age", 
                    "Median Age", 
                    "Age Range", 
                    "Sex (Male)", 
                    "Sex (Female)", 
                    "Ethnicity (HISPANIC OR LATINO)", 
                    "Ethnicity (NOT HISPANIC OR LATINO)", 
                    "Placebo", 
                    "Xanomeline High Dose", 
                    "Xanomeline Low Dose", 
                    "Screen Failure"
                    ),
  Count = c(
    total_count,
    round(mean(clinical_data$Age), 2),
    round(median(clinical_data$Age), 2),
    paste0(round(min(clinical_data$Age), 2), " - ", round(max(clinical_data$Age), 2)),
    ifelse("Male" %in% names(sex_table), sex_table["Male"], 0),
    ifelse("Female" %in% names(sex_table), sex_table["Female"], 0),
    ethnicity_table["HISPANIC OR LATINO"],
    ethnicity_table["NOT HISPANIC OR LATINO"],
    treatment_table["Placebo"],
    treatment_table["Xanomeline High Dose"],
    treatment_table["Xanomeline Low Dose"],
    treatment_table["Screen Failure"]
  ),
  Percentage = c(
    NA,
    NA, 
    NA,
    NA,
    round(ifelse("Male" %in% names(sex_table), sex_table["Male"], 0) / total_count * 100, 2), 
    round(ifelse("Female" %in% names(sex_table), sex_table["Female"], 0) / total_count * 100, 2), 
    round(ethnicity_table["HISPANIC OR LATINO"] / total_count * 100, 2),
    round(ethnicity_table["NOT HISPANIC OR LATINO"] / total_count * 100, 2),
    round(treatment_table["Placebo"] / total_count * 100, 2),
    round(treatment_table["Xanomeline High Dose"] / total_count * 100, 2),
    round(treatment_table["Xanomeline Low Dose"] / total_count * 100, 2),
    round(treatment_table["Screen Failure"] / total_count * 100, 2)
  ),
  stringsAsFactors = FALSE
)

# Define the output file path
output_file_path <- "~/path/output/TFL/lst_demo.docx"

# Create a new Word document and add the table with a different style
doc <- read_docx() %>%
  body_add_par("Listing of Demographic Characteristics", style = "heading 1") %>%
  body_add_table(value = lst_demo, style = "Normal")  


# Save the document
print(doc, target = output_file_path)
# Check if the file was created successfully
file.exists(output_file_path)
# Attempt to read the document back
doc_read <- read_docx(output_file_path)
# Print message to confirm if it was read successfully
if (!is.null(doc_read)) {
  cat("Document read successfully.\n")
} else {
  cat("Failed to read the document.\n")
}

