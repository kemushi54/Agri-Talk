# scrape crop-pest-agent info from BAPHIQ

#-- load library
library(readxl)
library(data.table)
library(magrittr)
library(rvest)
library(writexl)
library(dplyr)

#---- chemical
#-- import url needed (crop-pest)
url.dat <-
  read_xlsx("data/1210更新玉米化學與非化學藥劑防治.xlsx",
            sheet = 1) %>% 
  setDT %>% 
  # remove non-link item
  .[`防治藥劑` %like% "https"]

#-- scrape part
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

#-- export as xlsx
write_xlsx(content, "Results/Baphiq_info.xlsx")

content <- 
  read_xlsx("Results/Baphiq_info.xlsx") %>% 
  setDT %>% 
  .[, list(`目標作物` = Crop,
           `蟲害種類` = Pest,
           `藥劑名稱` = `普通名稱`,
           # `使用時期`,
           `施藥間隔`,
           `安全採收期`
           )] %>% 
  unique

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

# bind two source of item agent-item contect
item.all <- 
  rbind(item, item.2) %>% 
  unique %>% 
  setDT %>% 
  .[is.na(`商品名稱`) | `商品名稱` == "" | `商品名稱` %like% "\\*|＊", 
    `商品名稱` := sprintf("%s的%s", `廠商名稱`, `藥劑名稱`)] %>% 
  .[, `廠商名稱` := gsub("台灣", "臺灣", `廠商名稱`)] %>% 
  unique

# # agent list
# agent.list <- 
#   item.all[, "藥劑名稱"] %>% unique

# write_xlsx(agent.list, "Results/藥劑清單.xlsx")

# non-chemical and rename info
agent.info <- 
  read_xlsx("data/藥劑清單_梁力仁修改.xlsx") %>% 
  setDT %>% 
  .[is.na(修正), 修正 := 藥劑名稱]

# modified item.all
item.all.md <- 
  agent.info[, 1:3][item.all, on = "藥劑名稱"] %>% 
  .[is.na(非化學藥劑)] %>% 
  .[, 藥劑名稱 := NULL] %>% 
  unique

# modified content
content.md <- 
  agent.info[, 1:2][content, on = "藥劑名稱"] %>% 
  .[, 藥劑名稱 := NULL] %>% 
  unique


#-- merge all together with item name
final.dat <- 
  inner_join(content.md, item.all.md) %>% 
  unique %>% 
  setDT %>% 
  setnames("修正", "藥劑名稱")

#-- extract maiz part of data
maiz.dat <- 
  final.dat[`目標作物` == "甜玉米"]

write_xlsx(maiz.dat, "Results/甜玉米化學藥劑商品關聯.xlsx")

#---- non-chemical maiz
#-- pest-agent
dat.1 <- 
  read_xlsx("data/1210更新玉米化學與非化學藥劑防治.xlsx",
            sheet = 2) %>%
  setDT %>% 
  .[, list(`目標作物` = `TGAP品項`,
           `蟲害種類` = `TGAP害蟲`,
           `藥劑名稱` = `生物農藥`)] %>% 
  .[`目標作物` == "甜玉米"]

dat.2 <- 
  read_xlsx("data/1210梁力仁補充 蟲體描述與非化學資材表.xlsx",
            sheet = 2) %>% 
  setDT %>% 
  .[, list(`目標作物` = "甜玉米",
         `蟲害種類` = 防治對象,
         `藥劑名稱` = 非化學農藥防治)] %>% 
  .[`蟲害種類` %in% dat.1$`蟲害種類`]

non.che.all <- 
  rbind(dat.1, dat.2) %>% 
  setDT %>% 
  unique %>% 
  .[!is.na(`藥劑名稱`)]

#-- agent-item
item.dat.1 <- 
  read_xlsx("data/生物性農藥-已取證之生物農藥產品(含連絡資訊).xlsx",
            sheet = 2, skip = 2) %>% 
  setDT %>% 
  .[, list(`藥劑名稱` = `普通名稱`,
           `商品名稱` = `商品名`,
           `廠商名稱` = `登記廠商`)] %>% 
  .[!is.na(`商品名稱`)]

item.dat.2 <- 
  read_xlsx("data/非化學藥劑-商品化免登記資材與病蟲害表.xlsx",
            sheet = 1) %>% 
  setDT %>% 
  .[, list(`藥劑名稱` = `資 材 品 項`,
           `商品名稱` = `商 品 名 稱`,
           `廠商名稱` = `廠 商 名 稱`)] %>% 
  .[!is.na(`藥劑名稱`)]


item.dat.3 <- 
  agent.info[, 1:3][item.all, on = "藥劑名稱"] %>% 
  .[非化學藥劑 == 1] %>% 
  .[, list(`藥劑名稱` = `修正`,
           `商品名稱`,
           `廠商名稱`)]
  
  
non.che.item.all <- 
  list(item.dat.1, item.dat.2, item.dat.3) %>%
  do.call(rbind, .) %>% 
  unique %>% 
  inner_join(non.che.all, .)

write_xlsx(non.che.item.all, "Results/甜玉米非化學藥劑商品關聯.xlsx")
