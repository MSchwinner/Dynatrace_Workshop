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
  
  orders_payments <- reactive({
    
    data$olist_order_payments_dataset %>% 
      left_join(orders_purchase() %>% select(order_id, order_purchase_date), by = "order_id") %>% 
      filter(!is.na(order_purchase_date))
    
  })
  
  product_df <- reactive({

    orders_items() %>%
      group_by(product_id) %>%
      summarize(Revenue = sum(price),
                Freight = sum(freight_value)) %>% 
      mutate(Profit = round(Revenue - Freight,2),
             Margin = paste0(round(Profit / Revenue*100,2),"%")) %>% 
      left_join(data$olist_products_dataset %>% select(product_id, product_category_name), by = "product_id") %>% 
      arrange(desc(Revenue))
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
      nice_num(sum(df_daily()$Orders)),
      "Orders", 
      color = "purple",
      icon = icon("shopping-cart")
    )
  })
  
  output$box_revenue_order <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Revenue) / sum(df_daily()$Orders)),
      "Revenue per Order", 
      color = "purple",
      icon = icon("dollar-sign")
      
    )
  })
  
  output$box_profit_order <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Profit) / sum(df_daily()$Orders)),
      "Profit per Order", 
      color = "purple",
      icon = icon("money")
    )
  })
  
  output$box_revenue <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Revenue)),
      "Revenue", 
      color = "purple",
      icon = icon("dollar-sign")
    )
  })
  
  output$box_profit <- renderValueBox({
    valueBox(
      bd(sum(df_daily()$Profit)),
      "Profit", 
      color = "purple",
      icon = icon("money")
    )
  })
  
  output$box_margin <- renderValueBox({
    valueBox(
      paste0(round(sum(df_daily()$Profit) / sum(df_daily()$Revenue)*100,1),"%"),
      "Margin", 
      color = "purple",
      icon = icon("percentage")
    )
  })
  
  output$box_credit <- renderValueBox({
    valueBox(
      nice_num((orders_payments() %>% filter(payment_type == "credit_card") %>% count())$n),
      "Credit Card Payments",
      color = "purple",
      icon = icon("credit-card")
    )
  })
  
  output$box_boleto <- renderValueBox({
    valueBox(
      nice_num((orders_payments() %>% filter(payment_type == "boleto") %>% count())$n),
      "Ticket Payments",
      color = "purple",
      icon = icon("ticket")
    )
  })
  
  output$box_voucher <- renderValueBox({
    valueBox(
      nice_num((orders_payments() %>% filter(payment_type == "voucher") %>% count())$n),
      "Voucher Payments",
      color = "purple",
      icon = icon("vimeo")
    )
  })
  

# product -----------------------------------------------------------------

  
    
    output$plot_product <- renderPlotly({
    
      if (length(input$cat) == 0) {
        
      product_df() %>% 
        slice(1:20) %>% 
        plot_ly(., x = ~reorder(paste0(substr(product_id,1,5),"..."), -Revenue), y = ~Revenue,
                type = "bar", color = ~product_category_name) %>% 
        layout(xaxis = list(title = ""))
        
      } else {
        
        product_df() %>% 
          filter(product_category_name %in% input$cat) %>% 
          slice(1:20) %>% 
          plot_ly(., x = ~reorder(paste0(substr(product_id,1,5),"..."), -Revenue), y = ~Revenue,
                  type = "bar", color = ~product_category_name) %>% 
          layout(xaxis = list(title = ""))
        
      }
    
  })
  
  output$table_product <- renderDataTable(server = FALSE,{

    nice_dt(product_df())

  })

# timeseries --------------------------------------------------------------
    
  output$table_test <- renderDataTable({
    
    nice_dt(df_daily())
    
  })
  
  output$plot_ts <- renderPlotly({
    
    if (input$level == "week") {    
      
      df <- df_daily() %>% 
                    mutate(week = format.Date(order_purchase_date, "%Y%V")) %>% 
                    select(-order_purchase_date) %>% 
                    group_by(week) %>% 
                    summarize_all(., sum)
      
    } else if (input$level == "month") {
      
      df <- df_daily() %>% 
        mutate(month = format.Date(order_purchase_date, "%Y%m")) %>% 
        select(-order_purchase_date) %>% 
        group_by(month) %>% 
        summarize_all(., sum)
      
    } else {
      
      df <- df_daily() %>% 
        mutate(day = order_purchase_date)
    }
    
    df <- df %>% 
      mutate(Margin = Profit / Revenue,
             "Revenue per Order" = Revenue / Orders,
             "Profit per Order" = Profit / Orders) %>% 
      rename(x = input$level,
             y = input$kpi) 

    plot_ly(df, x = ~x, y = ~y,
            type = "bar") %>% 
      layout(xaxis = list(title = input$level),
             yaxis = list(title = input$kpi))
    
  })

# payments ----------------------------------------------------------------
  
  output$plot_payments <- renderPlotly({
    
    orders_payments() %>% 
      group_by(payment_type) %>% 
      count() %>% 
      plot_ly(., labels = ~payment_type, values = ~n, type = 'pie')
    
  })
  
  output$table_payments <- renderDataTable({

    nice_dt(orders_payments())

  })
  

# forecast ----------------------------------------------------------------

  output$forecasting <- renderUI({
    
    includeHTML(path = "forecasting.html")
    
  })  
  
}