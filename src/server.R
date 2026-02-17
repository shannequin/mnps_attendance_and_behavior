#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


function(input, output, session) {
    
    output$display_table <- renderDT({
        
        if (input$area_input == "Metro Nashville Public Schools") {
            
            subgroup_column_name <- str_to_upper(str_replace_all(input$subgroup_input, " ", "_"))
            
            if (input$behavior_input == "Suspension") {
                mnps_behavior_df |>
                    filter(SUBGROUP == input$subgroup_input) |>
                    select(SCHOOL, DATA_VALUE, TOTAL_SUBGROUP_ENROLLMENT, SUSPENSION) |>
                    rename(TOTAL_STUDENTS = TOTAL_SUBGROUP_ENROLLMENT, !!subgroup_column_name := DATA_VALUE)
            } else if (input$behavior_input == "Chronic Absenteeism") {
                mnps_absent_df |> 
                    group_by(STUDENT_GROUP) |> 
                    summarise(
                        TOTAL_STUDENTS = sum(N_STUDENTS),
                        TOTAL_ABSENT = sum(ABSENT_COUNT, na.rm = TRUE)
                    )
                
                mnps_absent_df |> 
                    mutate(ABSENTEEISM = str_c(ABSENT_PERCENT, "%")) |> 
                    select(SCHOOL_NAME, STUDENT_GROUP, N_STUDENTS, ABSENTEEISM) |> 
                    rename(SCHOOL = SCHOOL_NAME, !!subgroup_column_name := STUDENT_GROUP, TOTAL_STUDENTS = N_STUDENTS)
            }
        } else if (input$area_input == "State of TN") {
            if (input$behavior_input == "Suspension") {
                NA
            } else if (input$behavior_input == "Chronic Absenteeism") {
                school_absent_df
            }
        }
    })
    
    output$display_graph <- renderPlot({
        
        subgroup_column_name <- str_to_upper(str_replace_all(input$subgroup_input, " ", "_"))
        
        if (input$area_input == "Metro Nashville Public Schools") {
            if (input$behavior_input == "Suspension") {
                mnps_behavior_df |>
                    filter(SCHOOL == "*DISTRICT" & SUBGROUP == input$subgroup_input) |>
                    # Create column for calculated number of students suspended
                    mutate(SUSPENSION_COUNT = round(TOTAL_SUBGROUP_ENROLLMENT * SUSPENSION_PERCENT / 100)) |>
                    select(DATA_VALUE, TOTAL_SUBGROUP_ENROLLMENT, SUSPENSION, SUSPENSION_COUNT) |>
                    rename(!!subgroup_column_name := DATA_VALUE, TOTAL_ENROLLMENT = TOTAL_SUBGROUP_ENROLLMENT) |>
                    # Move TOTAL_ENROLLMENT and SUSPENSION_COUNT to COUNT_TYPE column
                    pivot_longer(cols = c(TOTAL_ENROLLMENT, SUSPENSION_COUNT),
                                 names_to = "COUNT_TYPE",
                                 values_to = "COUNT") |>
                    ggplot(aes(x = .data[[subgroup_column_name]],
                               y = COUNT,
                               fill = COUNT_TYPE,
                               label = case_match(COUNT_TYPE,
                                                  "SUSPENSION_COUNT" ~ SUSPENSION,
                                                  "TOTAL_ENROLLMENT" ~ as.character(COUNT))
                    )) +
                    # Layer cols in front of each other
                    geom_col(position = "identity") +
                    labs(title = glue("Suspension by ", input$subgroup_input),
                         #      subtitle = "MNPS District",
                         x = input$subgroup_input,
                         y = "Number of Students",
                         fill = NULL) +
                    scale_fill_hue(labels = c("SUSPENSION_COUNT" = "Suspended Students",
                                              "TOTAL_ENROLLMENT" = "Total Students"),
                                   guide = guide_legend(reverse = TRUE)) + # Reverse order of legend labels
                    # Display geom labels
                    geom_label(colour = "white",
                               fontface = "bold",
                               key_glyph = draw_key_rect)
            } else if (input$behavior_input == "Chronic Absenteeism") {
                mnps_absent_df |>
                    group_by(STUDENT_GROUP) |> 
                    summarise(
                        TOTAL_STUDENTS = sum(N_STUDENTS),
                        TOTAL_ABSENT = sum(ABSENT_COUNT, na.rm = TRUE)
                    ) |> 
                    mutate(ABSENT_PERCENT = str_c(as.character(round(TOTAL_ABSENT / TOTAL_STUDENTS * 100, digit = 1)), "%")) |> 
                    pivot_longer(
                        cols = c(TOTAL_STUDENTS, TOTAL_ABSENT),
                        names_to = "COUNT_TYPE",
                        values_to = "COUNT"
                    ) |> 
                    ggplot(
                        aes(
                            x = STUDENT_GROUP,
                            y = COUNT,
                            fill = COUNT_TYPE,
                            label = case_match(COUNT_TYPE,
                                               "TOTAL_ABSENT" ~ ABSENT_PERCENT,
                                               "TOTAL_STUDENTS" ~ as.character(COUNT))
                        )
                    ) +
                    geom_col(position = "identity") +
                    labs(title = glue("Chronic Absenteeism by ", input$subgroup_input),
                         x = input$subgroup_input,
                         y = "Number of Students",
                         fill = NULL) +
                    scale_fill_hue(labels = c("TOTAL_ABSENT" = "Absent Students",
                                              "TOTAL_STUDENTS" = "Total Students"),
                                   # Reverse order of legend labels
                                   guide = guide_legend(reverse = TRUE)) +
                    # Display geom labels
                    geom_label(colour = "white",
                               fontface = "bold",
                               key_glyph = draw_key_rect)
            }
        } else if (input$area_input == "State of TN") {
            if (input$behavior_input == "Suspension") {
                NA
            } else if (input$behavior_input == "Chronic Absenteeism") {
                school_absent_df |> ggplot(aes()) + geom_col()
            }
        }
    })
}
