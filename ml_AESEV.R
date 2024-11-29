install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    message(paste("Installing", package))
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  } else {
    message(paste(package, "is already installed and loaded as a library."))
  }
}

# List of packages to install
packages <- c("tidyverse", "caret", "admiral", "ggplot2", "nnet", "haven", "remotes", "pharmaverseadam")

# Install each package in the list
for (pkg in packages) {
  install_if_missing(pkg)
}

adae <- pharmaverseadam::adae 
unique(adae$TRTEMFL)

# Preprocess the dataset
# Include only treatment-emergent events
# Select relevant variables
# Treatment group, Serious adverse event and Gender as a factorda
ae_filtered <- adae %>%
  filter(TRTEMFL == "Y") %>%  
  select(TRT01A, AESER, AESEV, AGE, SEX, TRTEMFL) %>%  
  mutate(
    AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE")), 
    TRT01A = as.factor(TRT01A),  
    AESER = as.factor(AESER),    
    SEX = as.factor(SEX)         
  ) %>%
  drop_na(AESEV)

# Check the structure of the data
str(ae_filtered)


#training sets creation
set.seed(999)  
index <- createDataPartition(ae_filtered$AESEV, p = 0.8, list = FALSE)
training_data <- ae_filtered[index, ]
test_data <- ae_filtered[-index, ]
head(training_data)
head(test_data)

# Train the multi-nomial logistic regression model
model <- multinom(AESEV ~ TRT01A + AESER + AGE + SEX, data = training_data)
summary(model)

test_data$Predictive_AESEV <- predict(model, test_data)
head(test_data[, c("AESEV", "Predictive_AESEV")])

# Confusion matrix to evaluate model accuracy
conf_matrix <- confusionMatrix(test_data$Predictive_AESEV, test_data$AESEV)
print(conf_matrix)


#graphical representation of our model's prediction
ggplot(test_data, aes(x = AESEV, fill = Predictive_AESEV)) +
  geom_bar(position = "dodge") +
  labs(title = "Actual vs Predicted Severity", x = "Actual Severity", y = "Count") +
  theme_minimal()

#Extracting and plotting the coefficients
coef_summary <- as.data.frame(summary(model)$coefficients)

# Visualize coefficients
coef_summary <- coef_summary %>%
  rownames_to_column("Variable") %>%
  pivot_longer(-Variable, names_to = "Severity", values_to = "Estimate")

ggplot(coef_summary, aes(x = Variable, y = Estimate, fill = Severity)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(title = "Variable Impact on Severity", x = "Variables", y = "Coefficient") +
  theme_minimal()

