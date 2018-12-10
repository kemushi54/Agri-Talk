# library(readxl)
library(data.table)
library(magrittr)
library(rvest)
library(writexl)

# Sys.setlocale("LC_ALL", "C")
# Sys.getlocale(category = "LC_ALL")


test.url <- 
  "https://pesticide.baphiq.gov.tw/web/Insecticides_MenuItem5_5_B.aspx?tp=1&id1=B030107&id2=A010106&sign=X"

content <- 
  read_html(test.url) %>% 
  html_nodes("table#GridView1") %>% 
  html_table %>% 
  as.data.frame

tttt.url <- 
  "https://pesticide.baphiq.gov.tw/web/Insecticides_MenuItem5_5.aspx?fbclid=IwAR0338cG-ggIad981OY7nE8p1quZ04a6qbCQ_uSifFqyCHEFG51LMHu-Rbs"


cot <- 
  read_html(tttt.url) %>% 
  html_nodes("#ctl00_ContentPlaceHolder1_updPnl td")[3] %>% 
  html_table(., fill = TRUE)
  html_nodes(xpath = '//*[(@id = "ctl00_ContentPlaceHolder1_updPnl")]/table[2]') %>%
  html_text

"#ctl00_ContentPlaceHolder1_updPnl table"
//*[@id="ctl00_ContentPlaceHolder1_updPnl"]/table[2]/tbody/tr[2]/td