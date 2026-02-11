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

        # Show a plot of the generated distribution
        mainPanel(
            DTOutput("mnps_table"),
            plotOutput("mnps_plot") 
        )
    )
)
