### use item name to get photo url (google search engine)
library(readxl)
library(rvest)
library(magrittr)
library(stringr)

# reload modidied TGAP_data
item <- 
  read_xlsx("Results/甜玉米化學藥劑商品關聯.xlsx") %>% 
  .$商品名稱

search.item <- 
  item[!str_detect(item, "的")] %>% 
  unique

google.url <- sprintf("https://www.google.com.tw/search?q=%s&source=lnms&tbm=isch&sa=X&ved=0ahUKEwi4ibz_te3eAhXIXLwKHVe5AWIQ_AUIDigB&biw=1280&bih=610",
                      search.item)

# get url of item image search from google
google.image.url <- 
  lapply(google.url, 
         function(x)
           read_html(x) %>% 
           html_nodes(xpath = '//img') %>% 
           html_attr("src") %>% 
           .[1])

# download image to folder
# lapply(search.item, 
#        function(x)
#          ifelse(dir.exists(sprintf("Results/%s", x)), 
#                 FALSE, 
#                 dir.create(sprintf("Results/%s", x))))
lapply(1:length(google.image.url),
       function(x)
         download.file(google.image.url[[x]], 
                       sprintf("Results/item_IMG/item_%03d.jpg", x),
                       mode = "wb")) %>% 
  invisible

item.list <- 
  data.table(ID = 1:length(google.image.url),
             item = google.image.url)