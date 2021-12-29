
library(tidyverse)

#### Cargar bases
get(load('input/data_Rdata/bases_ENE_1.Rdata'))
get(load('input/data_Rdata/bases_ENE_2.Rdata'))
get(load('input/data_Rdata/bases_ENE_3.Rdata'))

## Crear lista con las bases
dfs <- Filter(function(x) is(x, "data.frame"), mget(ls(pattern = "ene_")))

## Crear tabla vacía
base<-ls(pattern = "ene_") %>% as.data.frame()
rm(list=ls(pattern = "ene_"))
names(base)<-"periodo"
base<-base %>% filter(periodo!="dfs")
base<-base %>% mutate(ocupados_agro=NA)


i<-1
for (i in 1:nrow(base)){
  base[i,2]<-dfs[[i]] %>% 
    as.data.frame() %>% 
    mutate(fact_cal=as.numeric(stringr::str_replace_all(fact_cal,",","."))) %>% 
    filter(categoria_ocupacion>0) %>% 
    filter(b14_rev4cl_caenes==1) %>% 
 #   filter(ocup_form==1) %>%                      ## filtro formales, optativo
    select(fact_cal) %>% 
    sum()
}



plot(base$ocupados_agro,type = "l")

# writexl::write_xlsx(base,"ocupados agricultura ENE formales.xlsx")

library(scales)

base %>% 
  mutate(fecha=stringr::str_remove_all(periodo,"ene_"),
         fecha=lubridate::make_date(year=substr(fecha,1,4),
                                    month = substr(fecha,6,7) ,day="01")) %>% 
  ggplot(aes(x=fecha,y=ocupados_agro))+
  geom_line()+
  theme_bw()+
  labs(title = "Ocupados en Agricultura.") +
  scale_x_date(labels = date_format("%Y-%b"),breaks='1 year' ) + 
  scale_y_continuous(labels=function(x) format(x, big.mark = ".", scientific = FALSE),
                     limits = c(400000,900000)) +  
  theme(legend.position = "bottom")

ggsave(
  plot = last_plot(),
  filename = "output/graficos/agro/ocupados_agricultura.png",
  device = "png",
  dpi = "retina",
  units = "cm",
  width = 20,
  height = 15
)






