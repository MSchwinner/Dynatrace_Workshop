server <- function(input, output, session) {
  
# Data --------------------------------------------------------------------

  orders_purchase <- reactive({
    
    data$olist_orders_dataset %>%
      filter(as_date(order_purchase_timestamp) >= input$time[[1]] &
               as_date(order_purchase_timestamp) <= input$time[[2]])
  })
  
  orders_items <- reactive({
    
    data$olist_order_items_dataset %>%
      filter(order_id %in% orders_purchase()$order_id)
  })
  
  product_df <- reactive({

    orders_items() %>%
      group_by(product_id) %>%
      summarize(Orders = n(),
                Revenue = sum(price),
                Freight = sum(freight_value)) %>% 
      mutate(Profit = round(Revenue - Freight,2),
             Margin = paste0(round(Profit / Revenue*100,2),"%")) %>% 
      left_join(data$olist_products_dataset %>% select(product_id, product_category_name), by = "product_id") %>% 
      arrange(desc(Orders))
  })

# Dashboard ---------------------------------------------------------------

  output$box_orders <- renderValueBox({
    valueBox(
      length(unique(orders_purchase()$order_id)),
      "Orders", 
      color = "purple"
    )
  })
  
  output$box_deliveries <- renderValueBox({
    valueBox(
      length(unique((orders_purchase() %>% filter(order_delivered_customer_date != ""))$order_id)),
      "Successfull Deliveries", 
      color = "purple"
    )
  })
  
  output$box_success <- renderValueBox({
    valueBox(
      paste0(round(length(unique((orders_purchase() %>% filter(order_delivered_customer_date != ""))$order_id)) /
        length(unique(orders_purchase()$order_id)) *100,1), " %"),
      "Success Rate", 
      color = "purple"
    )
  })
  
  output$box_revenue <- renderValueBox({
    valueBox(
      sum(product_df()$Revenue),
      "Revenue", 
      color = "purple"
    )
  })
  
  output$box_profit <- renderValueBox({
    valueBox(
      sum(product_df()$Profit),
      "Profit", 
      color = "purple"
    )
  })
  
  output$box_margin <- renderValueBox({
    valueBox(
      paste0(round(sum(product_df()$Profit) / sum(product_df()$Revenue)*100,1),"%"),
      "Margin", 
      color = "purple"
    )
  })
  
  output$table_product <- renderDataTable({

    datatable(product_df())

  })
}