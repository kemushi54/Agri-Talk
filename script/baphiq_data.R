# scrape crop-pest-agent info from BAPHIQ

#-- load library
library(readxl)
library(data.table)
library(magrittr)
library(rvest)
library(writexl)
library(dplyr)

# import url needed (crop-pest)
url.dat <-
  read_xlsx("data/防檢局作物蟲害對應化學藥劑資料表.xlsx",
            col_names = TRUE) %>% 
  setDT %>% 
  # remove non-link item
  .[`防治藥劑` %like% "https"]

# scrape part
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

# export as xlsx
write_xlsx(content, "Results/Baphiq_info.xlsx")

content <- 
  read_xlsx("Results/Baphiq_info.xlsx") %>% 
  setDT %>% 
  .[, list(`目標作物` = Crop,
           `蟲害種類` = Pest,
           `藥劑名稱` = `普通名稱`,
           `使用時期`,
           `施藥間隔`,
           `安全採收期`
           )]

#-- import info of agent-item
# source 1
item <- 
  fread("data/農藥名稱手冊.csv") %>% 
  .[, list(`藥劑名稱` = Name, 
           `商品名稱` = ProductName,
           `廠商名稱` = CompanyName)] %>% 
  unique
# source 2
item.2 <- 
  read_xlsx("data/農藥資料查詢.xlsx") %>% 
  setDT %>% 
  .[, list(`藥劑名稱` = `中文名稱`,
           `商品名稱` = `廠牌名稱`,
           `廠商名稱`)] %>% 
  unique

item.all <- 
  rbind(item, item.2) %>% 
  unique %>% 
  setDT %>% 
  .[is.na(`商品名稱`) | `商品名稱` == "" | `商品名稱` %like% "\\*|＊", 
    `商品名稱` := sprintf("%s的%s", `廠商名稱`, `藥劑名稱`)] %>% 
  .[, `廠商名稱` := gsub("台灣", "臺灣", `廠商名稱`)] %>% 
  unique

agent.list <- 
  item.all[, "藥劑名稱"] %>% unique

# merge all together with item name
final.dat <- 
  inner_join(content, item.all) %>% 
  unique %>% 
  setDT

maiz.dat <- 
  final.dat[`目標作物` == "甜玉米"]

write_xlsx(maiz.dat, "Results/甜玉米資訊.xlsx")
