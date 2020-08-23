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
                             icon = shiny::icon("dolly")),
    shinydashboard::menuItem(text = 'Time Series', tabName = 'ts',
                             icon = shiny::icon("chart-line")),
    shinydashboard::menuItem(text = 'Payments', tabName = 'pay',
                             icon = shiny::icon("money")),
    shinydashboard::menuItem(text = 'Business Case: Forecast', tabName = 'fc',
                             icon = shiny::icon("random"))
    
  ),
  
  shiny::br(),
  
  shiny::h4(shiny::img(src = "https://images.endeavor.org.br/uploads/2018/05/11180447/0022_olist.png",
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

body <- shinydashboard::dashboardBody(
  
  tags$head(tags$style(HTML(".small-box {height: 150px}"))),
  
  shinydashboard::tabItems(

# dashboard ---------------------------------------------------------------
    
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
      ,fluidRow(
        valueBoxOutput("box_credit"),
        valueBoxOutput("box_boleto"),
        valueBoxOutput("box_voucher")
      )
      
      ),

# products ----------------------------------------------------------------

    shinydashboard::tabItem(
      
      tabName = "prod",
      
      fluidRow(
        box(title = "",
            status = "primary",
            width = 2,
            selectInput("cat", "Filter categories:",
                        choices = unique(data$olist_products_dataset$product_category_name),
                        selected = "",
                        multiple = TRUE)
            ),
        box(title = "Top 20 Products by Revenue",
            status = "primary",
            width = 10,
            plotlyOutput("plot_product")
        )
      ),
      
      fluidRow(
      box(title = "",
          status = "primary",
          width = 12,
          dataTableOutput("table_product"))
      )
    ),

# timeseries --------------------------------------------------------------
    
    shinydashboard::tabItem(
      
      tabName = "ts",
      
      fluidRow(
        box(title = "",
            status = "primary",
            width = 2,
            selectInput("kpi",
                        "Choose KPI:",
                        choices = c(colnames(daily_df[-1]),"Margin", "Revenue per Order", "Profit per Order"),
                        selected = "Orders"),
            radioButtons("level",
                         "Choose Time Level:",
                         choices = c("day", "week", "month"),
                         selected = "day")
            ),
        box(title = "Time Series Analysis",
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

# payments ----------------------------------------------------------------

      ,shinydashboard::tabItem(

        tabName = "pay",
        
        fluidRow(
          box(
            title = "Frequency of Payment Types",
            status = "primary",
            width = 12,
            plotlyOutput("plot_payments")
          )
        ),

        fluidRow(
          box(
            title = "",
            status = "primary",
            width = 12,
            dataTableOutput("table_payments")
          )
        )

      )

# forecast ----------------------------------------------------------------

      ,shinydashboard::tabItem(
        
        tabName = "fc",
        
        htmlOutput("forecasting")
        
        )

    
  )
  
)

ui <- shinydashboard::dashboardPage(skin = "blue",
                                    header,
                                    sidebar,
                                    body)