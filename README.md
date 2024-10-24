# R_CDP
This repository has R codes used in Clinical Data Programming like creating ADaMs, Tables, Listings, and Figures from clinical trial data.

## Overview
Welcome to the **Clinical Data Programming in R** repository! This project contains R scripts and Shiny applications for creating Analysis Data Models (ADaMs), tables, listings, and figures from clinical trial data. The code adheres to industry standards and best practices for clinical data reporting.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Directory Structure](#directory-structure)
- [Code Overview](#code-overview)
- [Contributing](#contributing)

## Prerequisites
Before you begin, ensure you have the following installed:

- R (version 4.0 or higher)
- RStudio (recommended)
- Required R packages:
  - `dplyr`
  - `tidyr`
  - `ggplot2`
  - `shiny`
  - `haven`
  - `DT`
  - `lubridate`

You can install the required packages using the following command in R:

```r
install.packages(c("dplyr", "tidyr", "ggplot2", "shiny", "haven", "DT", "lubridate"))
```

## Installation
Clone the repository to your local machine:

```bash
git clone https://github.com/yourusername/R_CDP.git
```
Set your working directory to the cloned repository:

```r
setwd("path/to/R_CDP")
```

## Usage
Example Scripts
Creating ADaMs: scripts/ADaM/adsls.R
Generating Tables: scripts/Tables/table_demog.R
Creating Listings: scripts/Listings/listing_demog.R
Generating Figures: scripts/Figures/barplot_age_ranges.R
Shiny Applications: shiny_app.R

You can run a script in R by sourcing it:

```r
source("scripts/Listings/listing_demog.R")
```

## Directory Structure
```bash
R_CDP/
│
├── data/                 # Directory for input data files (e.g., .xpt, .csv)
│
├── outputs/              # Directory for generated output files (e.g., reports, figures)
│
├── scripts/              # R scripts organized by clinical programming type
│   ├── ADaM/             # R scripts for creating ADaMs
│   │   └── adsls.R
│   ├── Tables/           # R scripts for generating tables
│   │   └── table_demog.R
│   ├── Listings/         # R scripts for creating listings
│   │   └── listing_demog.R
│   └── Figures/          # R scripts for generating figures
│       └── barplot_age_ranges.R
│
└── shiny_app.R           # Shiny application for interactive data analysis
```

## Code Overview
This repository includes code for the following functionalities:

ADaMs: Scripts in scripts/ADaM/ folder to create analysis datasets following CDISC ADaM standards.
Example: adsls.R creates subject-level analysis datasets.

Tables: Scripts in scripts/Tables/ to generate summary tables for clinical trial reporting.
Example: table_demog.R generates demographic summary tables.

Listings: Scripts in scripts/Listings/ to create listings of subject data or trial outcomes.
Example: listing_demog.R generates listings of demographic characteristics.

Figures: Scripts in scripts/Figures/ for creating visualizations of clinical trial data using ggplot2.
Example: barplot_age_ranges.R creates a bar plot of age ranges following CDISC standards.

Shiny App: An interactive Shiny application for visualizing clinical trial data.

## Contributing
Contributions are welcome! If you would like to contribute to this repository, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes.
4. Push to your branch and submit a pull request.
