#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# Define server logic required to draw a histogram
function(input, output, session) {
    
    # Data table that displays suspension based on subgroup input
    output$mnps_table <- renderDT({
        
        subgroup_column_name <- str_to_upper(str_replace_all(input$mnps_subgroup, " ", "_")) # Format column name for subgroup
        
        mnps_behavior_df |>
            filter(SUBGROUP == input$mnps_subgroup) |> # Filter by subgroup input
            select(SCHOOL, TOTAL_SUBGROUP_ENROLLMENT, DATA_VALUE, SUSPENSION) |> # Select columns
            rename(TOTAL_ENROLLMENT = TOTAL_SUBGROUP_ENROLLMENT, !!subgroup_column_name := DATA_VALUE) # Rename columns
    })
    
    # Col plot that displays suspension based on subgroup input    
    output$mnps_plot <- renderPlot({
        
        subgroup_column_name <- str_to_upper(str_replace_all(input$mnps_subgroup, " ", "_")) # Format column name for subgroup
        
        mnps_behavior_df |>
            filter(SCHOOL == "*DISTRICT" & SUBGROUP == input$mnps_subgroup) |> # Filter by district totals and subgroup
            mutate(SUSPENSION_COUNT = round(TOTAL_SUBGROUP_ENROLLMENT * SUSPENSION_PERCENT / 100)) |> # Create column for calculated number of students suspended
            select(DATA_VALUE, TOTAL_SUBGROUP_ENROLLMENT, SUSPENSION, SUSPENSION_COUNT) |> # Select columns
            rename(!!subgroup_column_name := DATA_VALUE, TOTAL_ENROLLMENT = TOTAL_SUBGROUP_ENROLLMENT) |> # Rename columns
            pivot_longer(cols = c(TOTAL_ENROLLMENT, SUSPENSION_COUNT), # Move TOTAL_ENROLLMENT and SUSPENSION_COUNT to COUNT_TYPE column
                         names_to = "COUNT_TYPE",
                         values_to = "COUNT") |> 
            ggplot(aes(x = .data[[subgroup_column_name]],
                       y = COUNT,
                       fill = COUNT_TYPE,
                       label = case_match(COUNT_TYPE,
                                          "SUSPENSION_COUNT" ~ SUSPENSION, # Use SUSPENSION as label for suspended students
                                          "TOTAL_ENROLLMENT" ~ as.character(COUNT)) # Use COUNT as label for total students
            )) +
            geom_col(position = "identity") + # Layer cols in front of each other
            labs(title = glue("Suspension by ", input$mnps_subgroup),
                 #      subtitle = "MNPS District",
                 x = input$mnps_subgroup,
                 y = "Number of Students",
                 fill = NULL) +
            scale_fill_hue(labels = c("SUSPENSION_COUNT" = "Suspended Students",
                                      "TOTAL_ENROLLMENT" = "Total Students"),
                           guide = guide_legend(reverse = TRUE)) + # Reverse order of legend labels
            # Display geom labels
            geom_label(colour = "white",
                       fontface = "bold",
                       key_glyph = draw_key_rect)
    })
}
