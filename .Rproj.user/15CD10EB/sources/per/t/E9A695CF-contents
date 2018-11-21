# web scraping test
# 植物保護手冊 http://web.tari.gov.tw/techcd
# 玉米 url: http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/%E7%8E%89%E7%B1%B3-%E8%9F%B2%E5%AE%B3.htm 

#-- load library
library(rvest)
library(magrittr)
library(data.table)
library(stringr)
#-- 
# for url
url.1 <- "http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/%E7%8E%89%E7%B1%B3-%E7%8E%89%E7%B1%B3%E8%9A%9C.htm" 

all.url <- 
  read_html(url.1)
xpath <- '/html/body/table[2]/'

# 可以擷取到第一個玉米蚜之外的物種
content <- 
  html_nodes(all.url, "tr td font a") %>% 
  xml_text

# "tr td font"

### 文字轉url連結

### for loop or lapply 藥劑資訊


### 文字ok，要想辦法表格化
# for content
pest.info <- 
  read_html("http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/%E7%8E%89%E7%B1%B3-%E7%8E%89%E7%B1%B3%E8%9A%9C.htm")

xpath <- '//*[@id="table2"]'

a <- 
  xml_find_all(pest.info, xpath) %>% 
  xml_attr("href")

pest.text <- 
  xml_text(a) %>% 
  str_replace_all("\\s", "_") %>% 
  str_split(pattern = "_") %>% 
  unlist

text.clean <- 
  pest.text[pest.text != ""]