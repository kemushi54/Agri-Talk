# crop - pest - pest cotrol
# 植物保護手冊 http://web.tari.gov.tw/techcd
# 玉米 url: http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/%E7%8E%89%E7%B1%B3-%E8%9F%B2%E5%AE%B3.htm

#-- load library
library(rvest)
library(magrittr)
library(data.table)
library(RCurl)
library(tidyr)
library(writexl)
### url main page of maiz
url.maiz <- "http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/%E7%8E%89%E7%B1%B3-%E8%9F%B2%E5%AE%B3.htm"

### get pest url list form main page
pest.list.ori <- 
  read_html(url.maiz) %>% 
  html_nodes("tr td font a") %>% 
  html_attr("href") %>% 
  .[24:length(.)]
  
pest.list.url <- 
  curlEscape(pest.list.ori)

### 用文字轉url取得每個物種連結
# pattern url.1: 玉米-蟲害 --> 玉米-蟲害名稱

url.0 <- "http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/"

pest.url <- sprintf("%s%s", 
                    url.0, pest.list.url)
### use lapply get 藥劑資訊
pest.info <- 
  lapply(1:length(pest.url), 
         function(x)
           read_html(pest.url[x]) %>% 
           html_table(fill = TRUE) %>% 
           lapply(function(i)
             if(dim(i)[2] == 5){i}) %>% 
           do.call(rbind, .) %>% 
           setDT %>% 
           .[-1] %>% 
           .[, Pest := pest.list.ori[x]]
  ) %>% 
  do.call(rbind, .)
  
### cleaning table
pest.info.clean <- 
  pest.info %>% 
  setnames(names(pest.info)[1:5], 
           paste0(pest.info[1, 1:5])) %>% 
  .[!(藥劑名稱 %like% "藥劑名稱|費雯綺")]
write_xlsx(pest.info.clean,
           "agent_info_maiz.xlsx")
