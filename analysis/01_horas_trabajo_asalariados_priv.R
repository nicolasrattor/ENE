
# carga paquetes

library(tidyverse)
library(lubridate)
library(survey)
library(srvyr)

# Cargar bases 

get(load('input/data_Rdata/bases_ENE_1.Rdata'))
get(load('input/data_Rdata/bases_ENE_2.Rdata'))
get(load('input/data_Rdata/bases_ENE_3.Rdata'))

gc()

options(survey.lonely.psu = "certainty" ) 

## Horas automático ####

dfs <- Filter(function(x) is(x, "data.frame"), mget(ls(pattern = "ene")))

base<-ls(pattern = "ene") %>% as.data.frame()
names(base)<-"periodo"
base<-base %>% mutate(horas=NA,
                      horas_low=NA,
                      horas_upp=NA)


i<-1
for (i in 1:nrow(base)){

  # renombrar variable conglomerado si es que no existe
  if(sum(dfs[[i]]$id_directorio)>0){
  dfs[[i]]$conglomerado <- dfs[[i]]$id_directorio
  }
  
  # renombrar variable conglomerado si es que no existe
  if(sum(dfs[[i]]$estrato_unico)>0){
    dfs[[i]]$estrato <- dfs[[i]]$estrato_unico
  }
  
  # diseño muestral
  ds <- dfs[[i]] %>% as.data.frame() %>% as_survey_design(ids = conglomerado,   
                                        strata = estrato,     
                                        weights = fact_cal) 
  # horas
  horas <- ds %>% filter(activ==1&categoria_ocupacion==3) %>% 
    summarise(c2_1_3= survey_total(c2_1_3,na.rm = TRUE,vartype=c("ci")))
  
  # nt
  nt    <- ds %>% filter(activ==1&categoria_ocupacion==3) %>% 
    summarise(nt= survey_total(na.rm = TRUE,vartype=c("ci")))
  
  # horas / nt
  base[i,2:4]<-horas/nt 
}


# Dar año y mes
base<-base %>% mutate(ano_trimestre=NA,mes_central=NA)
for (i in 1:nrow(base)){
  base[i,5]<-dfs[[i]] %>% as.data.frame() %>% select(ano_trimestre) %>% slice(1)
  base[i,6]<-dfs[[i]] %>% as.data.frame() %>% select(mes_central) %>% slice(1)
}

base<-base %>% mutate(trimestre=make_date(year=ano_trimestre,month = mes_central))


# grafico 

base %>% 
  ggplot(aes(trimestre,horas)) +
  geom_line() +
#  geom_errorbar(aes(ymin=horas_low, ymax=horas_upp), width=.01,
#                color="red") +
  theme_bw() +
  labs(title = "Horas de trabajo semanales promedio 2010-2021",
       subtitle = "Trabajadores/as asalariados/as sector privado",
       caption = "Encuesta Nacional de Empleo (ENE)") 

# Guardar gráfico

ggsave(
  plot = last_plot(),
  filename = "output/graficos/horas/horas_trabajo_priv.png",
  device = "png",
  dpi = "retina",
  units = "cm",
  width = 15,
  height = 10
)
