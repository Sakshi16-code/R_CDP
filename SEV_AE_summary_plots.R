library(dplyr)
library(tidyr)
library(pharmaverse)
library(ggplot2)
adae <- pharmaverseadam::adae

# Find maximum severity for each subject
max_severity <- adae %>%
  group_by(USUBJID) %>%
  filter(ASEVN == max(ASEVN)) %>%
  ungroup()
max_severity <- max_severity %>%
  distinct()

# View the subjects with their maximum severity
print(max_severity)

severity_summary <- max_severity %>%
  group_by(TRT01A) %>% 
  reframe(
    Total_Subjects = n_distinct(USUBJID),                     # Total unique subjects
    Severity_Distribution = paste(names(table(ASEVN)),        # Format distribution as text
                                  table(ASEVN), sep = ":", collapse = ", "),
    Most_Common_AE = names(sort(table(AETERM), decreasing = TRUE)[1]), # Most frequent AE
    Average_Severity = mean(ASEVN, na.rm = TRUE) #life threat
  ) 

print(summary_stats)

top_5_AEs <- max_severity %>%
  group_by(TRT01A) %>%
  count(AETERM) %>%  # Count occurrences of each adverse event
  arrange(TRT01A, desc(n)) %>%  # Sort by treatment and count
  group_by(TRT01A) %>%
  slice_head(n = 5) %>%  # Select top 5 most frequent AEs
  ungroup()

# Print the top 5 most frequent adverse events per treatment
print(top_5_AEs)

#barplot
ggplot(top_5_AEs, aes(x = reorder(AETERM, n), y = n, fill = AETERM)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~ TRT01A, scales = "free_y") +  # Create a separate plot for each treatment arm
  labs(
    title = "Top 5 Most Frequent Adverse Events by Treatment",
    x = "Adverse Event",
    y = "Frequency",
    caption = "Data Source: ADAE dataset"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels for readability
    plot.title = element_text(hjust = 0.5),
    strip.text = element_text(size = 12)
  )
