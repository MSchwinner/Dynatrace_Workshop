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
                     min = min(as_date(data$olist_orders_dataset$order_purchase_timestamp)),
                     max = max(as_date(data$olist_orders_dataset$order_purchase_timestamp)),
                     value = c(as_date("2017-07-01"), as_date("2018-07-01"))
  ),
  
  shiny::br(),
  
  shinydashboard::sidebarMenu(
    
    shinydashboard::menuItem(text = 'Dashboard', tabName = 'dash',
                             icon = shiny::icon("compress")),
    shinydashboard::menuItem(text = 'Products', tabName = 'prod',
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
    
    # Dashboard body: tab1 --------------------------------------------------
    
    shinydashboard::tabItem(
      
      tabName = "dash",
      
      fluidRow(
      valueBoxOutput("box_orders"),
      valueBoxOutput("box_deliveries"),
      valueBoxOutput("box_success")
      )
      ,fluidRow(
        valueBoxOutput("box_revenue"),
        valueBoxOutput("box_profit"),
        valueBoxOutput("box_margin")
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
      
      
    )
    
  )
  
)

ui <- shinydashboard::dashboardPage(skin = "blue",
                                    header,
                                    sidebar,
                                    body)