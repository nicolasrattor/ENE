


library(tidyverse)
library(lubridate)
library(ggrepel)
library(scales)

gc()
## Cargar bases
get(load('input/data_Rdata/bases_ENE_1.Rdata'))
get(load('input/data_Rdata/bases_ENE_2.Rdata'))
get(load('input/data_Rdata/bases_ENE_3.Rdata'))


dfs <- Filter(function(x) is(x, "data.frame"), mget(ls(pattern="ene")))

base<-ls(pattern="ene") %>% as.data.frame()
names(base)<-"periodo"
base<-base %>% filter(periodo!="dfs")
base<-base %>% mutate(N=NA)


for (i in 1:nrow(base)){
  base[i,2]<-dfs[[i]] %>% 
    as.data.frame() %>% 
    select(fact_cal) %>% 
    mutate(fact_cal=as.numeric(stringr::str_replace_all(fact_cal,",","."))) %>% 
    sum()
}

base
