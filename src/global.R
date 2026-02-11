library(shiny)
library(DT)
library(tidyverse)
library(janitor) # Cleans names of a data.frame
library(glue)

# Read data
mnps_behavior_df <- read_csv("../data/MNPS Behavior Data 031025.csv")

# Rename tibble columns with janitor
mnps_behavior_df <- mnps_behavior_df |> clean_names("screaming_snake")

# Clean MNPS behavior data
mnps_behavior_df <- mnps_behavior_df |> 
    # Create new columns for numeric percentages and ignore suppressed values
    mutate(SUSPENSION_PERCENT = if_else(str_detect(SUSPENSION, "<|>"), NA, SUSPENSION), .after = SUSPENSION) |> 
    mutate(EXPULSION_PERCENT = if_else(str_detect(EXPULSION, "<|>"), NA, EXPULSION), .after = EXPULSION) |> 
    mutate(REMANDMENT_PERCENT = if_else(str_detect(REMANDMENT, "<|>"), NA, REMANDMENT), .after = REMANDMENT) |>  
    # Convert the columns from char to double
    mutate(SUSPENSION_PERCENT = as.double(str_replace(SUSPENSION_PERCENT, "%", "")), .after = SUSPENSION) |>
    mutate(EXPULSION_PERCENT = as.double(str_replace(EXPULSION_PERCENT, "%", "")), .after = EXPULSION) |>
    mutate(REMANDMENT_PERCENT = as.double(str_replace(REMANDMENT_PERCENT, "%", "")), .after = REMANDMENT)

# Set list of categories
mnps_subgroup_list <- mnps_behavior_df |>
    distinct(SUBGROUP) |> 
    pull() |> 
    sort()

