library(readxl)
library(data.table)
library(magrittr)
library(rvest)
library(writexl)

url.dat <-
  read_xlsx("data/防檢局作物蟲害對應化學藥劑資料表.xlsx",
            col_names = TRUE) %>% 
  setDT %>% 
  # remove non-link item
  .[`防治藥劑` %like% "https"]


content <- 
  lapply(1:nrow(url.dat), 
         function(x)
           tryCatch({
             read_html(url.dat$防治藥劑[x]) %>% 
               html_nodes("table#GridView1") %>% 
               html_table  %>%
                as.data.table %>%
               .[, Crop := url.dat$TGAP品項[x]] %>%
               .[, Pest := url.dat$TGAP害蟲[x]]
             # Sys.sleep(2)
             },
             error = function(msg){
               message(paste(url.dat$TGAP品項[x], url.dat$TGAP害蟲[x], 
                             sep = "_", collapse = "\r"))
             })
  ) %>%
  do.call(rbind, .)

write_xlsx(content, "Results/Baphiq_info.xlsx")


###############################
# join with item name
item <- 
  fread("data/農藥名稱手冊.csv") %>% 
  .[, list(`普通名稱` = Name, 
           EnName)] %>% 
  unique
item.2 <- 
  read_xlsx("data/農藥資料查詢.xlsx") %>% 
  setDT %>% 
  .[, list(`普通名稱` = `中文名稱`,
           EnName = `英文名稱`)] %>% 
  unique

item.all <- 
  rbind(item, item.2) %>% 
  .[, EnName := "TT"] %>% 
  unique

final.dat <- 
  item.all[content, on = "普通名稱"]
