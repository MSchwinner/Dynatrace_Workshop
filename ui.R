# Header -----------------------------------------------------------------------

header <- shinydashboard::dashboardHeader(
  title = "Olist Performance Dashboard",
  titleWidth = 310
)


# Sidebar ----------------------------------------------------------------------

sidebar <- shinydashboard::dashboardSidebar(
  
  width = 350,
  
  shiny::sliderInput(inputId = 'time',
                     label = 'Time:',
                     min = min(as_date(daily_df$order_purchase_date)),
                     max = max(as_date(daily_df$order_purchase_date)),
                     value = c(as_date("2017-07-01"), as_date("2018-07-01"))
  ),
  
  shiny::br(),
  
  shinydashboard::sidebarMenu(
    
    shinydashboard::menuItem(text = 'Dashboard', tabName = 'dash',
                             icon = shiny::icon("compress")),
    shinydashboard::menuItem(text = 'Products', tabName = 'prod',
                             icon = shiny::icon("compress")),
    shinydashboard::menuItem(text = 'Time Series', tabName = 'ts',
                             icon = shiny::icon("compress")),
    shinydashboard::menuItem(text = 'Forecast', tabName = 'fc',
                             icon = shiny::icon("compress"))
    
  ),
  
  shiny::br(),
  
  shiny::h4(#shiny::HTML('&emsp;'),shiny::HTML('&emsp;'),
            shiny::img(src = "https://images.endeavor.org.br/uploads/2018/05/11180447/0022_olist.png",
             height = "60px")),
  
  shiny::br(),
  
  shiny::h4(shiny::HTML('&emsp;'),
            "Built with",
            shiny::img(src = "https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png",
                       height = "40px"),
            "by",
            shiny::img(src = "https://rstudio.com/wp-content/uploads/2018/10/RStudio-Logo.png",
                       height = "40px"),
            "."
  )
  
)


# Dashboard body ---------------------------------------------------------------

# Initialize dashboard body ----------------------------------------------------

body <- shinydashboard::dashboardBody(
  
  shinydashboard::tabItems(
    
    shinydashboard::tabItem(
      
      tabName = "dash",
      
      fluidRow(
      valueBoxOutput("box_orders"),
      valueBoxOutput("box_revenue"),
      valueBoxOutput("box_revenue_order")
      )
      ,fluidRow(
        valueBoxOutput("box_margin"),
        valueBoxOutput("box_profit"),
        valueBoxOutput("box_profit_order")
      )
      
      ),
    
    shinydashboard::tabItem(
      
      tabName = "prod",
      
      fluidRow(
      box(title = "",
          status = "primary",
          width = 12,
          dataTableOutput("table_product"))
      )
    ),
    
    shinydashboard::tabItem(
      
      tabName = "ts",
      
      fluidRow(
        box(title = "",
            status = "primary",
            width = 2,
            selectInput("kpi",
                        "Choose KPI:",
                        choices = colnames(daily_df[-1]),
                        selected = "Orders"),
            radioButtons("level",
                         "Choose Time Level:",
                         choices = c("day", "week", "month"),
                         selected = "day")
            ),
        box(title = "",
            status = "primary",
            width = 10,
            plotlyOutput("plot_ts"))
      ),
      
      fluidRow(
        box(title = "",
            status = "primary",
            width = 12,
            dataTableOutput("table_test"))
      )
    )
    
    # ,shinydashboard::tabItem(
    # 
    #   tabName = "fc",
    # 
    #   box(includeHTML("forecasting.html"))
    # )
    
  )
  
)

ui <- shinydashboard::dashboardPage(skin = "blue",
                                    header,
                                    sidebar,
                                    body)