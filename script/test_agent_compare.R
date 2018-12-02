library(readxl)
library(data.table)
library(magrittr)

data.01 <- 
  read_xlsx("data/農藥資料查詢.xlsx") %>% 
  setDT

data.02 <- 
  fread("data/農藥名稱手冊.csv", encoding = "UTF-8")

TGAP <- 
  read_xlsx("data/TGAP甜玉米病蟲害.xlsx",
            sheet = 2) %>% 
  setDT

agent.list <- 
  data.02$Name %>% unique

test <- 
  lapply(1:length(agent.list), 
         function(x){
           agent.x <- agent.list[x]
           a <- TGAP[`使用防治資材` %like% agent.x] %>%  
             .[, Agent := agent.x]
           return(a)
           }
    ) %>% 
  do.call(rbind, .)
