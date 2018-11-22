# !!! do in Linux system !!!
# crop - pest checklist
# Zea mays L.

#-- load library
library(rvest)
library(magrittr)
library(data.table)
library(writexl)
# set environment to C
# Sys.setlocale(category="LC_ALL", locale="C")

# url of maize
url <- 
  sprintf("http://210.69.150.201/InsectTest/Search.asp?pageNo=%s&keyWord=&CropInum=10268",
          1:3)

# xpath location for pest table
xpath = '//*[@id="table32"]'

# scrape table and export as xlsx
checklist <- 
  lapply(1:length(url),
         function(x)
           read_html(url[x]) %>% 
           html_nodes(xpath = xpath) %>% 
           html_table(fill = TRUE) %>% 
           as.data.table(.[[1]]) %>% 
           .[5:55, 1:6]) %>% 
  do.call(rbind, .) %>% 
  write_xlsx("pest_checklist.xlsx")
