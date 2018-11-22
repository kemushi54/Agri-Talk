# crop - pest checklist

# Zea mays L.

#-- load library
library(rvest)
library(magrittr)
library(data.table)
library(XML)
library(RCurl)

# set environment to C
Sys.setlocale(category="LC_ALL", locale="C")

url <- sprintf("http://210.69.150.201/InsectTest/Search.asp?pageNo=%s&keyWord=&CropInum=10268",
               1:3)

# //*[@id="table32"]/tbody/tr[3]/td/table

t <- 
  getURL(url[1])
t2 <- readHTMLTable(t, 
                stringsAsFactors = FALSE)


####
temp <- readLines(url[1], encoding="big5")
temp <- iconv(temp, "big5", "utf8")
temp.file <- tempfile()
write(temp, temp.file)


test_doc = htmlParse(temp.file, encoding="utf8")
test <- readHTMLTable(test_doc)


####
txt=download.file(url[1],destfile="stockbig-5",quiet = TRUE)
system('iconv -f big-5  -t  UTF-8//IGNORE    stockbig-5  > stockutf-8')
data=htmlParse("stockutf-8",isURL=FALSE,encoding="utf-8\\IGNORE")
tdata=xpathApply(data,"//table[@class='table_grey_border']")
stock <- readHTMLTable(tdata[[1]], header=TRUE, stringsAsFactors=FALSE)
stock