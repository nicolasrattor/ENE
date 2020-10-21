
#-------------------------------------------------------------------------------#
# DESCARGA DE BASES DE DATOS ENE EN FORMATO SPSS
#-------------------------------------------------------------------------------#

# Versión 1.2
# 17/10/2020

# Fijar carpeta donde se guardarán archivos
setwd ("D:\\datos\\ene\\bases") # Equipo personal

# Limpiar entorno de trabajo
rm(list = ls())

# Paquetes utilizados
library(data.table)
library(lubridate)

#-------------------------------------------------------------------------------#
# Paso 1. Creación de carpetas
#-------------------------------------------------------------------------------#

for (w in c("csv","stata","spss")){
        if (!file.exists(paste(w,""))) {
                dir.create(paste(w,""))
        }} 

#-------------------------------------------------------------------------------#
# Paso 2. Creación de link
#-------------------------------------------------------------------------------#

link <- "http://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/"

actual <- year(now())
url <- c()
mes <- c()
ano <- c()

for (y in 2010:actual){
     for (i in c("01","02","03","04","05","06","07","08","09","10","11","12")){
          url <- append(url,(paste(link,y,"/formato-spss/ene-",y,"-",i,".sav", sep="")))
          mes <- append(mes,i)
          ano <- append(ano,y)
     }} 

#-------------------------------------------------------------------------------#
# Paso 3. Chequear existencia de URL (1/2)
#-------------------------------------------------------------------------------#

# Fuente: https://stackoverflow.com/questions/52911812/check-if-url-exists-in-r
valid_url <- function(url_in,t=2){
     con <- url(url_in)
     check <- suppressWarnings(try(open.connection(con,open="rt",timeout=t),silent=T)[1])
     suppressWarnings(try(close.connection(con),silent=T))
     ifelse(is.null(check), T, F)
}

true <- cbind(cbind(cbind(as.data.table(sapply(url,valid_url)),url),ano),mes)
names(true)[1] <- "valid"

#-------------------------------------------------------------------------------#
# Paso 4. Corrección de URL=FALSE
#-------------------------------------------------------------------------------#

# Identificación de trimestre
true$trim <- c("")
true$trim[true$mes=="01"] <- "def"
true$trim[true$mes=="02"] <- "efm"
true$trim[true$mes=="03"] <- "fma"
true$trim[true$mes=="04"] <- "mam"
true$trim[true$mes=="05"] <- "amj"
true$trim[true$mes=="06"] <- "mjj"
true$trim[true$mes=="07"] <- "jja"
true$trim[true$mes=="08"] <- "jas"
true$trim[true$mes=="09"] <- "aso"
true$trim[true$mes=="10"] <- "son"
true$trim[true$mes=="11"] <- "ond"
true$trim[true$mes=="12"] <- "nde"

# URL FALSE/TRUE
false <- true[(true$valid=="FALSE"),]
true <- true[!(true$valid=="FALSE"),]

# Reemplazar URL=FALSE
false$url <- as.character(false$url)
false$mes <- as.character(false$mes)

for (k in 1:length(false$trim)){
     false$url[k] <- (paste(link,false$ano[k],"/formato-spss/","ene-",false$ano[k],"-",false$mes[k],"-",false$trim[k],".sav", sep=""))
}

false$url[false$ano==2020] <- gsub("formato-spss", "spss", false$url[false$ano==2020])

spss <- rbind(true,false)
spss$trim <- NULL
spss$valid <- NULL

#-------------------------------------------------------------------------------#
# Paso 5. Corrección de URL irregular
#-------------------------------------------------------------------------------#

# Reemplazar URL irregular
# link <- "http://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2014/formato-spss/"
# spss$url[spss$ano==2014 & spss$mes=="08"] <- paste(link,"ene-2014-08-nde.dta", sep="")

#-------------------------------------------------------------------------------#
# Paso 6. Chequear existencia de URL tras primera corrección (2/2)
#-------------------------------------------------------------------------------#

spss <- cbind(as.data.table(sapply(spss$url,valid_url)),spss)
names(spss)[1] <- "valid"
spss <- spss[(spss$valid=="TRUE"),]
spss <- spss[order(spss$ano, spss$mes),]

#-------------------------------------------------------------------------------#
# Paso 7. Descargar bases
#-------------------------------------------------------------------------------#

destino <- c(paste("spss/ene_",spss$ano,"_",spss$mes,".sav", sep = ""))

# La siguiente función descarga sólo bases que no estén previamente guardadas.
for (i in seq_along(spss$url)){
        if(!file.exists(destino[i])){
                download.file(url = spss$url[i], destfile = destino[i], mode = "wb")
        }
        next
}

# Importante: RStudio Cloud se ejecuta en servidores de Linux. Para Windows,
# hay que hacer ajustes al comando download.file(), agregando mode = "wb". De no 
# se corre riesgo de que archivo .sav quede ilegible, como sucede con Stata.
