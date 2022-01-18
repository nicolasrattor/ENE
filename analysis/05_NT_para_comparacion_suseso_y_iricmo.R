
library(tidyverse)
library(survey)
library(srvyr)

## Cargar bases
get(load('input/data_Rdata/bases_ENE_2.Rdata'))
get(load('input/data_Rdata/bases_ENE_3.Rdata'))


## Crear lista con las bases

dfs <- Filter(function(x) is(x, "data.frame"), mget(ls(pattern="ene")))
remove(list=ls(pattern="ene"))
## Crear tabla vacía
base<-ls(pattern="ene") %>% as.data.frame()
names(base)<-"periodo"
base<-base %>% mutate(nt_contrato_asalariados=NA,
                      nt_contrato_asalariados_mas_5=NA)
remove(list=ls(pattern="ene"))
gc()
i<-1

## Todas las empresas
for (i in 1:nrow(base)){
  base[i,2]<-dfs[[i]] %>% 
    as.data.frame() %>% 
    filter(categoria_ocupacion==3 | categoria_ocupacion==4) %>%   ## Asalariados publicos y privados
    filter(!b14_rev4cl_caenes %in% c(1,19,20,21)) %>% 
    filter(b8==1) %>%                       ## filtro contrato
    select(fact_cal) %>% 
    sum()
}

## Empresas de 5 o más trab
for (i in 1:nrow(base)){
  base[i,3]<-dfs[[i]] %>% 
    as.data.frame() %>% 
    filter(categoria_ocupacion==3 | categoria_ocupacion==4) %>%   ## Asalariados publicos y privados
    filter(!b14_rev4cl_caenes %in% c(1,19,20,21)) %>% 
    filter(b8==1) %>%                       ## filtro contrato
    filter(b15_1!=1) %>%                    ## Quitar empresas con menos de 5 trabajadores
    select(fact_cal) %>% 
    sum()
}


plot(base$nt_contrato_asalariados,type = "l")
plot(base$nt_contrato_asalariados_mas_5,type = "l",col="red")

plot(base$nt_contrato_asalariados,type="l",col="red")
lines(base$nt_contrato_asalariados_mas_5,col="green")

writexl::write_xlsx(base,"output/tabulados/nt/ocupados asalariados privados y publicos ENE contrato.xlsx")



# Lo mismo pero ahora con IC vía survey package e informales
datos<-base %>% 
  select(periodo) %>% 
  mutate(nt_contrato_asalariados=NA,
         nt_contrato_asalariados_low=NA,
         nt_contrato_asalariados_upp=NA,
         nt_contrato_asalariados_mas_5=NA,
         nt_contrato_asalariados_mas_5_low=NA,
         nt_contrato_asalariados_mas_5_upp=NA)


for (i in 1:nrow(base)){
  base<-dfs[[i]] %>% 
    as.data.frame() %>% 
    filter(categoria_ocupacion==3 | categoria_ocupacion==4) %>%   ## Asalariados publicos y privados
    filter(!b14_rev4cl_caenes %in% c(1,19,20,21)) %>% 
    filter(b8==1)                        ## filtro contrato
 #   filter(b15_1!=1)                        ## Quitar empresas con menos de 5 trabajadores

  try(base <- base %>% rename(conglomerado=id_identificacion))
  try(base <- base %>% rename(estrato_unico=estrato))
    
  base <- base %>% as_survey_design(id = conglomerado, strata = estrato_unico, weights = fact_cal, nest = TRUE) 
  options(survey.lonely.psu="remove")
  
  datos[i,2:4]<-base %>% summarise(nt=survey_total(vartype = "ci",na.rm = TRUE))
}


for (i in 1:nrow(base)){
  base<-dfs[[i]] %>% 
    as.data.frame() %>% 
    filter(categoria_ocupacion==3 | categoria_ocupacion==4) %>%   ## Asalariados publicos y privados
    filter(!b14_rev4cl_caenes %in% c(1,19,20,21)) %>% 
    filter(b8==1) %>%                         ## filtro contrato
    filter(b15_1!=1)                        ## Quitar empresas con menos de 5 trabajadores
  
  try(base <- base %>% rename(conglomerado=id_identificacion))
  try(base <- base %>% rename(estrato_unico=estrato))
  
  base <- base %>% as_survey_design(id = conglomerado, strata = estrato_unico, weights = fact_cal, nest = TRUE) 
  options(survey.lonely.psu="remove")
  
  datos[i,5:7]<-base %>% summarise(nt=survey_total(vartype = "ci",na.rm = TRUE))
}

writexl::write_xlsx(datos,"output/tabulados/nt/ocupados asalariados privados y publicos ENE contrato e IC.xlsx")









