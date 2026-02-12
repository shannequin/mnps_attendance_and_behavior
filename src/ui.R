#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# Define UI for application that draws a histogram
fluidPage(
    
    # Application title
    titlePanel("TN Schools Attendance & Behavior"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("mnps_subgroup", "Select category:",
                        choices = mnps_subgroup_list,
                        selected = "Gender")
        ),
        
        navset_card_tab(
            nav_panel(title = "Graphs", plotOutput("mnps_plot")),
            nav_panel(title = "Table", DTOutput("mnps_table")),
            nav_panel(title = "TAB 3", value = p("CONTENT3")),
            id = "selected_card_tab"
        )
        
        # Show a plot of the generated distribution
        # mainPanel(
        #     plotOutput("mnps_plot"),
        #     DTOutput("mnps_table")
        # )
    )
)
