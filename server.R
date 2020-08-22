server <- function(input, output, session) {
  
# Data --------------------------------------------------------------------

  orders_purchase <- reactive({
    
    data$olist_orders_dataset %>%
      mutate(order_purchase_date = as_date(order_purchase_timestamp)) %>% 
      filter(order_purchase_date >= input$time[[1]] &
               order_purchase_date <= input$time[[2]]) %>% 
      inner_join(data$olist_order_items_dataset, by = "order_id")
      
  })
  
  orders_items <- reactive({
    
    data$olist_order_items_dataset %>%
      filter(order_id %in% orders_purchase()$order_id)
  })
  
  product_df <- reactive({

    orders_items() %>%
      group_by(product_id) %>%
      summarize(Revenue = sum(price),
                Freight = sum(freight_value)) %>% 
      mutate(Profit = round(Revenue - Freight,2),
             Margin = paste0(round(Profit / Revenue*100,2),"%")) %>% 
      left_join(data$olist_products_dataset %>% select(product_id, product_category_name), by = "product_id") 
  })
  
  df_daily <- reactive({
    
    daily_df %>%
      filter(as_date(order_purchase_date) >= input$time[[1]] &
               as_date(order_purchase_date) <= input$time[[2]]) %>% 
      mutate(Profit = Revenue - Freight)
      
  })

# Dashboard ---------------------------------------------------------------

  output$box_orders <- renderValueBox({
    valueBox(
      sum(df_daily()$Orders),
      "Orders", 
      color = "purple"
    )
  })
  
  output$box_revenue_order <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Revenue) / sum(df_daily()$Orders)),
      "Revenue per Order", 
      color = "purple"
    )
  })
  
  output$box_profit_order <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Profit) / sum(df_daily()$Orders)),
      "Profit per Order", 
      color = "purple"
    )
  })
  
  output$box_revenue <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Revenue)),
      "Revenue", 
      color = "purple"
    )
  })
  
  output$box_profit <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Profit)),
      "Profit", 
      color = "purple"
    )
  })
  
  output$box_margin <- renderValueBox({
    valueBox(
      paste0(round(sum(df_daily()$Profit) / sum(df_daily()$Revenue)*100,1),"%"),
      "Margin", 
      color = "purple"
    )
  })
  

# product -----------------------------------------------------------------

  
  output$table_product <- renderDataTable({

    datatable(product_df())

  })

# timeseries --------------------------------------------------------------
    
  output$table_test <- renderDataTable({
    
    datatable(df_daily())
    
  })
  
  output$plot_ts <- renderPlotly({
    
    if (input$level == "week") {    
      
      df <- df_daily() %>% 
                    mutate(week = year(order_purchase_date) * 100 + isoweek(order_purchase_date)) %>% 
                    select(-order_purchase_date) %>% 
                    group_by(week) %>% 
                    summarize_all(., sum)
      
    } else if (input$level == "month") {
      
      df <- df_daily() %>% 
        mutate(month = year(order_purchase_date) * 100 + month(order_purchase_date)) %>% 
        select(-order_purchase_date) %>% 
        group_by(month) %>% 
        summarize_all(., sum)
      
    } else {
      
      df <- df_daily() %>% 
        mutate(day = order_purchase_date)
    }

    #FIXME: use inputs as columns
    plot_ly(df, x = ~!!input$level, y = ~!!input$kpi,
            type = "bar")
    
  })
}