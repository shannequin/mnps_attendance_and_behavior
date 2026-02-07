#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define UI for application that draws a histogram
fluidPage(

    # Application title
    titlePanel("TN Schools Attendance & Behavior"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("subgroup", "Select category:",
                        choices = subgroup_list)
            ),

        # Show a plot of the generated distribution
        mainPanel(
            dataTableOutput("selectedTable")
        )
    )
)
