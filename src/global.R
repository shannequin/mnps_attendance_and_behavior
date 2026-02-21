library(rsconnect)
library(shiny)
library(bslib)
library(DT)
library(tidyverse)
library(janitor) # Cleans names of a data.frame
library(glue)
library(scales)

YEAR_LIST <- c("2024-2025")
INCIDENT_LIST <- c("Suspensions", "Chronic Absenteesim")
GENDER_LIST <- c("All", "Male", "Female", "Non-binary")

mnps_behavior_2425_df <- read_csv("data/MNPS Behavior Data 031025.csv") |>
    clean_names("screaming_snake") |> 
    filter(SUBGROUP == "Gender") |>
    select(SCHOOL, TOTAL_SUBGROUP_ENROLLMENT, DATA_VALUE, SUSPENSION) |> 
    rename(TOTAL_STUDENTS = TOTAL_SUBGROUP_ENROLLMENT, GENDER = DATA_VALUE)

mnps_enrollment_df <- read_csv("data/MNPS Enrollment Data 031025.csv") |> clean_names("screaming_snake")

school_absent_df <- read_csv("data/school_chronic_absenteeism_suppressed_2025.csv") |> clean_names("screaming_snake")
