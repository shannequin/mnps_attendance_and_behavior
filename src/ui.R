fluidPage(
    
    titlePanel("Metro Nashville Schools: Attendance & Behavior"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("year_input", "Select school year:",
                        choices = YEAR_LIST,
                        selected = YEAR_LIST[1]),
            selectInput("incident_input", "Select incident type:",
                        choices = INCIDENT_LIST,
                        selected = INCIDENT_LIST[1]),
            selectInput("gender_input", "Select gender:",
                        choices = GENDER_LIST,
                        selected = GENDER_LIST[1])
        ),
        navset_card_tab(
            nav_panel(title = "Info", h3(htmlOutput("info_text"))),
            nav_panel(title = "Graph", plotOutput("display_graph")),
            nav_panel(title = "Table", DTOutput("display_table")),
            nav_panel(title = "Raw Data", DTOutput("raw_table")),
            id = "selected_card_tab"
        )
    )
)
