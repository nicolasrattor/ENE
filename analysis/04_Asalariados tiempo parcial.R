

## Crear lista con las bases
dfs <- Filter(function(x) is(x, "data.frame"), mget(ls(pattern = "ene")))

base<-ls(pattern="ene") %>% as.data.frame()
names(base)<-"periodo"
base<-base %>% filter(periodo!="dfs")
base<-base %>% mutate(tcp_mujeres=NA)


## Descubrir trimestres con más o menos de 21 sectores
for (i in 1:nrow(base)){
  
  dfs[[i]] %>% 
    as.data.frame() %>% 
    filter(categoria_ocupacion==3|categoria_ocupacion==4) %>% 
    filter(ocup_form==1) %>%        
    filter(!b14_rev4cl_caenes %in% c(20,21,999)) %>% 
    group_by(b14_rev4cl_caenes) %>% 
    mutate(fact_cal=as.numeric(stringr::str_replace_all(fact_cal,",","."))) %>% 
    summarise(asalariados=sum(fact_cal)) %>% 
    pivot_wider(names_from = b14_rev4cl_caenes,
                values_from = asalariados) %>% 
    ncol() %>% 
    paste0(.,"_",i) %>% 
    print()
  
}

## Crear tabla vacía
base<-ls(pattern = "ene_") %>% as.data.frame()
names(base)<-"periodo"
base<-base %>% filter(periodo!="dfs")
n <- 19
base <- data.frame(matrix(0, nrow = nrow(base), ncol = n,
                  dimnames = list(NULL, paste0("ColumnName_", 1:n))) )

base_pfijo <- base

## Asalariados formales por sector
for (i in 1:nrow(base)){
  
    base[i,]<-dfs[[i]] %>% 
    as.data.frame() %>% 
      mutate(fact_cal=as.numeric(stringr::str_replace_all(fact_cal,",","."))) %>% 
    filter(categoria_ocupacion==3|categoria_ocupacion==4) %>% 
    filter(ocup_form==1) %>%            
      filter(!b14_rev4cl_caenes %in% c(20,21,999)) %>% 
      group_by(b14_rev4cl_caenes) %>% 
    summarise(asalariados=sum(fact_cal)) %>% 
    pivot_wider(names_from = b14_rev4cl_caenes,
                values_from = asalariados)
  
}

## Asalariados formales plazo fijo por sector
for (i in 1:nrow(base_pfijo)){
base_pfijo[i,]<-dfs[[i]] %>% 
  as.data.frame() %>% 
  mutate(fact_cal=as.numeric(stringr::str_replace_all(fact_cal,",","."))) %>% 
  filter(categoria_ocupacion==3|categoria_ocupacion==4) %>% 
  filter(ocup_form==1) %>%   
  filter(!b14_rev4cl_caenes %in% c(20,21,999)) %>% 
  filter(b9==1) %>% 
  group_by(b14_rev4cl_caenes) %>% 
  summarise(asalariados=sum(fact_cal)) %>% 
  pivot_wider(names_from = b14_rev4cl_caenes,
              values_from = asalariados)
}

proporcionplazofijo <- base_pfijo/base
names(proporcionplazofijo)<-c("1 Agricultura, silvicultura y pesca",
                      "2 Explotación de minas y canteras",
                      "3 Industria Manufacturera",
                      "4 Suministro de electricidad, gas, vapor y aire acondicionado",
                      "5 Suministro de agua; alcantarillado, gestión de desechos y actividades de saneamiento",
                      "6 Construcción",
                      "7 Comercio",
                      "8 Transporte y almacenamiento",
                      "9 Alojamiento y servicios de comida",
                      "10 Información y comunicación",
                      "11 Actividades financieras y de seguros",
                      "12 Actividades inmobiliarias",
                      "13 Actividades profesionales, científicas y técnicas",
                      "14 Actividades administrativas y servicios deapoyo",
                      "15 Administración pública",
                      "16 Enseñanza",
                      "17 Servicios sociales y relacionados con la salud humana",
                      "18 Artes, entretenimiento y recreación",
                      "19 Otras actividades de servicios")


plot(proporcionplazofijo$`1 Agricultura, silvicultura y pesca`,type = "l")
plot(proporcionplazofijo$`2 Explotación de minas y canteras`,type = "l")
plot(proporcionplazofijo$`3 Industria Manufacturera`,type = "l")


writexl::write_xlsx(proporcionplazofijo,"output/graficos/fijo/proporcion asalariados formales plazo fijo por sector.xlsx")








