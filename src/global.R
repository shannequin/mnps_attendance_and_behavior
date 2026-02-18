library(rsconnect)
library(shiny)
library(bslib)
library(DT)
library(tidyverse)
library(janitor) # Cleans names of a data.frame
library(glue)

mnps_enrollment_df <- read_csv("data/MNPS Enrollment Data 031025.csv") |> clean_names("screaming_snake")
mnps_behavior_df <- read_csv("data/MNPS Behavior Data 031025.csv") |> clean_names("screaming_snake")
school_absent_df <- read_csv("data/school_chronic_absenteeism_suppressed_2025.csv") |> clean_names("screaming_snake")
region_df <- bind_rows(
    list(
        read_csv("data/tnsd_east_region.csv"),
        read_csv("data/tnsd_first_region.csv"),
        read_csv("data/tnsd_midcumberland_region.csv"),
        read_csv("data/tnsd_northwest_region.csv"),
        read_csv("data/tnsd_southcentral_region.csv"),
        read_csv("data/tnsd_southeast_region.csv"),
        read_csv("data/tnsd_southwest_region.csv"),
        read_csv("data/tnsd_uppercumberland_region.csv")
    )
) |> clean_names("screaming_snake")

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

# Set list of subgroups
mnps_subgroup_list <- mnps_behavior_df |>
    distinct(SUBGROUP) |> 
    pull() |> 
    sort()

# Clean school absent data
school_absent_df <- school_absent_df |> 
    mutate(
        ABSENT_COUNT = if_else(
            str_detect(N_CHRONICALLY_ABSENT, "<|>"),
            NA,
            as.double(N_CHRONICALLY_ABSENT)
        ),
        .after = N_CHRONICALLY_ABSENT
    ) |> 
    mutate(
        ABSENT_PERCENT = if_else(
            str_detect(PCT_CHRONICALLY_ABSENT, "<|>"),
            NA,
            as.double(PCT_CHRONICALLY_ABSENT)
        ),
        .after = PCT_CHRONICALLY_ABSENT
    ) |> 
    filter(STUDENT_GROUP %in% c("Male", "Female")) |> 
    select(SYSTEM_NAME, SCHOOL_NAME, STUDENT_GROUP, N_STUDENTS, ABSENT_COUNT, ABSENT_PERCENT)

# Create MNPS absent tibble
mnps_absent_df <- mnps_enrollment_df |>
    select(SCHOOL_NAME) |>
    left_join(
        school_absent_df,
        by = join_by(SCHOOL_NAME == SCHOOL_NAME)
    ) |> 
    filter(SYSTEM_NAME == "Davidson County")


mnps_absent_df <- mnps_absent_df |> 
    group_by(STUDENT_GROUP) |> 
    summarise(
        N_STUDENTS = sum(N_STUDENTS),
        ABSENT_COUNT = sum(ABSENT_COUNT, na.rm = TRUE)
    ) |> 
    mutate(SCHOOL_NAME = "*DISTRICT") |> 
    mutate(ABSENT_PERCENT = round(ABSENT_COUNT / N_STUDENTS * 100, digit = 1)) |> 
    full_join(
        mnps_absent_df
    )