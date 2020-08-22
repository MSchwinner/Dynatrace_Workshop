# import data
source("R/functions.R")
data <- import_csv_data(path = "Olist_data/")

# summarize item information to order
items_order <- data$olist_order_items_dataset %>%
  group_by(order_id) %>%
  summarize(Revenue = sum(price),
            Freight = sum(freight_value),
            Items = n())

# create daily df
daily_df <- data$olist_orders_dataset %>%
  inner_join(items_order, by = "order_id") %>%
  mutate(order_purchase_date = as_date(order_purchase_timestamp)) %>%
  group_by(order_purchase_date) %>% 
  summarize(Orders = n(),
            Revenue = sum(Revenue),
            Freight = sum(Freight),
            Customer = length(unique(customer_id)))

#save as RDS files
saveRDS(data, "data.RDS") 
saveRDS(daily_df, "daily_df.RDS")
