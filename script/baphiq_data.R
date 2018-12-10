library(readxl)
library(data.table)
library(magrittr)
library(rvest)
library(writexl)

# Sys.setlocale("LC_ALL", "C")
# Sys.getlocale(category = "LC_ALL")

# import url
url.dat <- 
  read_xlsx("data/蟲害與藥劑url.xlsx",
            col_names = FALSE)


test.url <- 
  "https://pesticide.baphiq.gov.tw/web/Insecticides_MenuItem5_5_B.aspx?tp=1&id1=B030107&id2=A010106&sign=X"

content <- 
  lapply(1:length(url.dat$X__2), 
         function(x)
           sprintf("https://pesticide.baphiq.gov.tw/web/%s", url.dat$`X__2`[x]) %>% 
           read_html() %>% 
           html_nodes("table#GridView1") %>% 
           html_table %>% 
           as.data.table %>% 
           .[, Pest := url.dat$X__1[x]]) %>% 
  do.call(rbind, .)
  
#########

tttt.url <- 
  "https://pesticide.baphiq.gov.tw/web/Insecticides_MenuItem5_5.aspx?fbclid=IwAR0338cG-ggIad981OY7nE8p1quZ04a6qbCQ_uSifFqyCHEFG51LMHu-Rbs"

cot <- 
  read_html(tttt.url) %>% 
  html_nodes(xpath = '//*[(@id="ctl00_ContentPlaceHolder1_updPnl")]') %>%
  html_text

"#ctl00_ContentPlaceHolder1_updPnl table"
//*[@id="ctl00_ContentPlaceHolder1_updPnl"]/table[2]/tbody/tr[2]/td