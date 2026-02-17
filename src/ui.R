#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#



fluidPage(
    
    titlePanel("TN Schools Attendance & Behavior"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("area_input", "Select Area:",
                        choices = c("State of TN", "Metro Nashville Public Schools"),
                        selected = "Metro Nashville Public Schools"),
            selectInput("subgroup_input", "Select subgroup:",
                        choices = mnps_subgroup_list,
                        selected = "Gender"),
            selectInput("behavior_input", "Select behavior:",
                        choices = c("Suspension", "Chronic Absenteeism"),
                        selected = "Suspension")
        ),
        navset_card_tab(
            nav_panel(title = "Graph", plotOutput("display_graph")),
            nav_panel(title = "Table", DTOutput("display_table")),
            id = "selected_card_tab"
        )
    )
)
