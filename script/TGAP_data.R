library(readxl)
library(data.table)
library(magrittr)
library(writexl)

TGAP <- 
  read_xlsx("data/TGAP甜玉米病蟲害.xlsx", sheet = 2) %>% 
  setDT %>% 
  .[, Agent := gsub("\\d|\\.|%|[a-zA-Z]|/", "", 使用防治資材)] %>% 
  .[, Agent := gsub("溶液|粒劑|可濕性|水分散性|乳劑|粉劑", "", Agent)]
  ## 無法處理：粒劑  

write_xlsx(TGAP, "Results/TGAP_data.xlsx")


### use pest name to get photo url (google search engine)
library(rvest)

search.pest.sci <- 
  TGAP$防治對象 %>% unique


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
  data.frame(pest.Sci = search.pest.sci,
             image.url = google.image.url)

write_xlsx(pest.google.image,
           "Results/TGAPpest_googleIMG.xlsx")

  