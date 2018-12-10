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
library(stringr)
### url main page of maiz
url.maiz <- "http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/%E7%8E%89%E7%B1%B3-%E8%9F%B2%E5%AE%B3.htm"

### get pest url list form main page
pest.list.ori <- 
  read_html(url.maiz) %>% 
  html_nodes("tr td font a") %>% 
  html_attr("href") %>% 
  .[24:length(.)]

# for C.Common name
pest.C <- 
  str_replace_all(pest.list.ori,
                  "玉米-|.htm", "")

# for scraping url  
pest.list.url <- 
  curlEscape(pest.list.ori)

### 用文字轉url取得每個物種連結
# pattern url.1: 玉米-蟲害 --> 玉米-蟲害名稱

url.0 <- "http://web.tari.gov.tw/techcd/%E8%94%AC%E8%8F%9C/%E6%9E%9C%E8%8F%9C%E9%A1%9E/%E7%8E%89%E7%B1%B3/%E8%9F%B2%E5%AE%B3/"

pest.url <- sprintf("%s%s", 
                    url.0, pest.list.url)

### pest scientific name
pest.sci <- 
  lapply(1:length(pest.url), 
         function(x)
           read_html(pest.url[x]) %>% 
           html_nodes("i span") %>% 
           html_text %>% 
           str_replace_all("\r|\n|\t", "") %>% 
           .[1]) %>%
  # turn to vextor
  do.call(rbind, .)

### use lapply get 藥劑資訊/ Scientific name
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
           .[, Pest := pest.C[x]] %>% 
           .[, Pest.Sci := pest.sci[x]]
  ) %>% 
  do.call(rbind, .)

  
### cleaning table
pest.info.clean <- 
  pest.info %>% 
  setnames(names(pest.info)[1:5], 
           paste0(pest.info[1, 1:5])) %>% 
  .[!(藥劑名稱 %like% "藥劑名稱|費雯綺")] %>% 
  separate("藥劑名稱", c("Agent.C", "Agent.E", "Other"), "\\(") %>% 
  .[!is.na(Other), Agent.E := Other] %>% 
  .[, Agent.E := str_replace(Agent.E, "\\)", "")] %>% 
  .[, Other := NULL]

write_xlsx(pest.info.clean,
           "pest_agent_maiz.xlsx")

### use pest.sci - photo url (google search engine)
search.pest.sci <- 
  str_split(pest.sci, " ") %>% 
  lapply(function(x)
    x[1:2] %>% 
      paste(., collapse = "+")) 
      

google.url <- sprintf("https://www.google.com.tw/search?q=%s&source=lnms&tbm=isch&sa=X&ved=0ahUKEwi4ibz_te3eAhXIXLwKHVe5AWIQ_AUIDigB&biw=1280&bih=610",
               search.pest.sci)

google.image.url <- 
  lapply(google.url, 
         function(x)
           read_html(x) %>% 
           html_nodes(xpath = '//img') %>% 
           html_attr("src") %>% 
           .[1]) %>% 
  do.call(rbind, .)

pest.google.image <- 
  data.frame(pest.Sci = pest.sci,
             image.url = google.image.url)
write_xlsx(pest.google.image,
           "pest_googleIMG.xlsx")

# download.file(t[1], "C:/kemushi/test.png",
#               mode = "wb")
