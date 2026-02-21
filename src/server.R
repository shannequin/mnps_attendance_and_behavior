function(input, output, session) {
    
    # FIRST TAB: Info about the dataset selected
    output$info_text <- renderText({
        
        suspension_2425_all <- paste(
            "The dataset used is displayed in the Raw Data tab.",
            "The graph is based on the School *DISTRICT observations which will not match up with the cleaned data counts.",
            "The Table contains only the data with matched pairs of M/F students after removing the suppressed observations.",
            sep = "<br><br>"
        )

        if (input$incident_input == "Suspensions") {
            
            HTML(
                case_match(
                    input$gender_input,
                    "All" ~ suspension_2425_all,
                    "Male" ~ "Male suspension info",
                    "Female" ~ "Female suspension info",
                    "Non-binary" ~ "No data :("
                )
            )
            
        } else if (input$incident_input == "Chronic Abesnteeims") {
            
            HTML(
                case_match(
                    input$gender_input,
                    "All" ~ "All chronic absenteeism info",
                    "Male" ~ "Male chronic absenteeism info",
                    "Female" ~ "Female chronic absenteeism info",
                    "Non-binary" ~ "No data :("
                )
            )
        }
    })
    
    # SECOND TAB: Graph the data
    output$display_graph <- renderPlot({
        
        if (input$year_input == "2024-2025" & input$incident_input == "Suspensions") {
            
            if (input$gender_input == "All") {
                
                mnps_behavior_2425_df |> 
                    filter(SCHOOL == "*DISTRICT") |>
                    mutate(SUSPENSION_PERCENT = as.double(str_replace(SUSPENSION, "%", "")), .after = SUSPENSION) |> 
                    mutate(SUSPENSION_COUNT = round(TOTAL_STUDENTS * SUSPENSION_PERCENT / 100)) |> 
                    pivot_longer(
                        cols = c(TOTAL_STUDENTS, SUSPENSION_COUNT),
                        names_to = "COUNT_TYPE",
                        values_to = "COUNT"
                    ) |> 
                    # Create a plot
                    ggplot(
                        aes(
                            x = GENDER,
                            y = COUNT,
                            fill = COUNT_TYPE,
                            label = case_match(
                                COUNT_TYPE,
                                "SUSPENSION_COUNT" ~ SUSPENSION,
                                "TOTAL_STUDENTS" ~ as.character(COUNT)
                            )
                        )
                    ) +
                    # Create bar graph with info layered in front of each other
                    geom_col(position = "identity") +
                    # Format labels
                    labs(
                        title = "Suspension by Gender",
                        subtitle = "MNPS District",
                        x = "Gender",
                        y = "Number of Students",
                        fill = NULL
                    ) +
                    # Format y-axis ticks
                    scale_y_continuous(labels = label_comma()) +
                    # Format fill
                    scale_fill_hue(
                        labels = c("SUSPENSION_COUNT" = "Suspended Students", "TOTAL_STUDENTS" = "Total Students"),
                        guide = guide_legend(reverse = TRUE)
                    ) +
                    # Format legend labels
                    geom_label(
                        colour = "white",
                        fontface = "bold",
                        key_glyph = draw_key_rect
                    )
            }
        }
    })
    
    # THIRD TAB: Formatted data table
    output$display_table <- renderDT({
        
        if (input$year_input == "2024-2025" & input$incident_input == "Suspensions") {
            
            if (input$gender_input == "All") {

                mnps_behavior_2425_df |> 
                    filter(SCHOOL != "*DISTRICT") |> 
                    mutate(SUSPENSION = if_else(str_detect(SUSPENSION, "<|>"), NA, SUSPENSION)) |>
                    mutate(SUSPENSION_PERCENT = as.double(str_replace(SUSPENSION, "%", "")), .after = SUSPENSION) |> 
                    mutate(SUSPENSION_COUNT = round(TOTAL_STUDENTS * SUSPENSION_PERCENT / 100), .after = SUSPENSION_PERCENT) |>
                    mutate(NON_SUSPENSION_COUNT = TOTAL_STUDENTS - SUSPENSION_COUNT, .after = SUSPENSION_COUNT) |>
                    pivot_wider(
                        names_from = GENDER,
                        names_glue = "{GENDER}_{.value}",
                        values_from = c(TOTAL_STUDENTS, SUSPENSION, SUSPENSION_PERCENT, SUSPENSION_COUNT, NON_SUSPENSION_COUNT)
                    ) |> 
                    drop_na()
            }
        }
    })
    
    # FOURTH TAB: Raw dataset
    output$raw_table <- renderDT({
        
        if (input$year_input == "2024-2025" & input$incident_input == "Suspensions") {
            mnps_behavior_2425_df
        }
        
    })
    
}
