library(readxl)
library(data.table)
library(magrittr)
library(writexl)

TGAP <- 
  read_xlsx("data/TGAP甜玉米病蟲害.xlsx", sheet = 2) %>% 
  setDT %>% 
  .[, Agent := gsub("\\d|\\.|%|[a-zA-Z]|/", "", 使用防治資材)] %>% 
  .[, Agent := gsub("溶液|粒劑|可濕性|水分散性|乳劑|粉劑", "", Agent)]
  ## 無法處理：粒劑  ( <- modified in excel)

write_xlsx(TGAP, "Results/TGAP_data.xlsx")


### use pest name to get photo url (google search engine)
library(rvest)

# reload modidied TGAP_data
TGAP <- 
  read_xlsx("Results/TGAP_data.xlsx")

search.pest.sci <- 
  TGAP$防治對象 %>% unique


google.url <- sprintf("https://www.google.com.tw/search?q=%s&source=lnms&tbm=isch&sa=X&ved=0ahUKEwi4ibz_te3eAhXIXLwKHVe5AWIQ_AUIDigB&biw=1280&bih=610",
                      search.pest.sci)

# get url of pest image search from google
google.image.url <- 
  lapply(google.url, 
         function(x)
           read_html(x) %>% 
           html_nodes(xpath = '//img') %>% 
           html_attr("src") %>% 
           .[1:10])

# download image to folder
lapply(search.pest.sci, 
       function(x)
         ifelse(dir.exists(sprintf("Results/%s", x)), 
                FALSE, 
                dir.create(sprintf("Results/%s", x))))
lapply(1:length(google.image.url),
       function(x)
         lapply(1:length(google.image.url[[x]]),
                function(i)
                  download.file(google.image.url[[x]][i], 
                                sprintf("Results/%s/IMG_%s.jpg",
                                        search.pest.sci[x], i),
                                mode = "wb"))) %>% 
  invisible

# pest.google.image <- 
#   data.frame(pest.Sci = search.pest.sci,
#              image.url = google.image.url)
# 
# write_xlsx(pest.google.image,
#            "Results/TGAPpest_googleIMG.xlsx")

