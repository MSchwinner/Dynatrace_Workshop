import_csv_data <- function(path = NULL) {
  
  # import csvs
  filenames = list.files(path = path, pattern="*.csv")
  
  filepath <- paste0(path, filenames)
  
  data <- lapply(filepath, read.csv) #import data in list
  
  #renaming
  df_names <- str_extract(filenames, '.*(?=\\.csv)')
  
  names(data) <- df_names
  
  return(data)
  
}

bd <- function(x) {
  
  paste0(format(round(x,1), big.mark = ","), " B$")
  
}

nice_num <- function(x) {
  
  format(x, big.mark = ",")
  
}

nice_dt <- function(df) {
  
  datatable(df,
            extensions = "Buttons",
            rownames = FALSE,
            options = list(scrollX = TRUE,
                          dom = "Bfrtip",
                          buttons = list('csv', 'excel')))
  
}