
#-------------------------------------------------------------------------------#
# DESCARGA DE BASES DE DATOS ENE EN FORMATO CSV
#-------------------------------------------------------------------------------#

# 27/12/2021
        
# Limpiar entorno de trabajo
rm(list = ls())

# Paquetes utilizados
library(data.table)
library(lubridate)

#-------------------------------------------------------------------------------#
# Paso 1. Creación de carpetas
#-------------------------------------------------------------------------------#

ifelse(
        dir.exists("input/data_csv"),
        print("Directorio existe"),
        dir.create("input/data_csv")
)

ifelse(
        dir.exists("input/data_sav"),
        print("Directorio existe"),
        dir.create("input/data_sav")
)


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
          url <- append(url,(paste(link,y,"/formato-csv/ene-",y,"-",i,".csv", sep="")))
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
     false$url[k] <- (paste(link,false$ano[k],"/formato-csv/","ene-",false$ano[k],"-",false$mes[k],"-",false$trim[k],".csv", sep=""))
}

csv <- rbind(true,false)
csv$valid <- NULL
csv$trim <- NULL

#-------------------------------------------------------------------------------#
# Paso 5. Corrección de URL irregular
#-------------------------------------------------------------------------------#

# Reemplazar URL irregular
csv$mes <- as.character(csv$mes)
csv$url <- as.character(csv$url)
link <- "http://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2014/formato-csv/"
csv$url[csv$ano==2014 & csv$mes=="08"] <- paste(link,"ene-2014.csv", sep="")

#-------------------------------------------------------------------------------#
# Paso 6. Chequear existencia de URL tras corrección (2/2)
#-------------------------------------------------------------------------------#

csv <- cbind(as.data.table(sapply(csv$url,valid_url)),csv)
names(csv)[1] <- "valid"
rownames(csv) <- NULL
csv <- csv[(csv$valid=="TRUE"),]
csv <- csv[order(csv$ano, csv$mes),]

#-------------------------------------------------------------------------------#
# Paso 7. Descargar bases
#-------------------------------------------------------------------------------#

destino <- c(paste("input/data_csv/ene_",csv$ano,"_",csv$mes,".csv", sep = ""))

# La siguiente función descarga sólo bases que no estén previamente guardadas.
for (i in seq_along(csv$url)){
        if(!file.exists(destino[i])){
                download.file(url = csv$url[i], destfile =destino[i], mode = "wb")
        }
        next
}


#-------------------------------------------------------------------------------#
# Paso 8. Corrección de bases con problemas en .csv - Deben descargarse en .sav
#-------------------------------------------------------------------------------#

# 2020-02 a 2020-08

destino <- "input/data_sav/ene_2020_02.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-02-efm.sav?sfvrsn=8adde4b3_14&download=true" , destfile = destino, mode = "wb") 
        }

destino <- "input/data_sav/ene_2020_03.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-03-fma.sav?sfvrsn=4515aeb9_18&download=true",destfile = destino, mode = "wb")
}

destino <- "input/data_sav/ene_2020_04.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-04-mam.sav?sfvrsn=e598f538_18&download=true",destfile = destino, mode = "wb")
}

destino <- "input/data_sav/ene_2020_05.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-05-amj.sav?sfvrsn=1fff738f_12&download=true",destfile = destino, mode = "wb")
}

destino <- "input/data_sav/ene_2020_06.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-06-mjj.sav?sfvrsn=86a38374_11&download=true",destfile = destino, mode = "wb")
}

destino <- "input/data_sav/ene_2020_07.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-07-jja.sav?sfvrsn=41536cf3_13&download=true",destfile = destino, mode = "wb")
}

destino <- "input/data_sav/ene_2020_08.sav"
if(!file.exists(destino)){
download.file("https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2020/spss/ene-2020-08-jas.sav?sfvrsn=8adde4b3_14&download=true",destfile = destino, mode = "wb")
}





#-------------------------------------------------------------------------------#
# Paso 9. Corrección de bases con problemas en .csv - No reconoce coma)
#-------------------------------------------------------------------------------#

link <- "http://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/"

actual <- year(now())
url <- c()
mes <- c()
ano <- c()

for (y in 2017:2019){
        for (i in c("01","02","03","04","05","06","07","08","09","10","11","12")){
                url <- append(url,(paste(link,y,"/formato-spss/ene-",y,"-",i,".sav", sep="")))
                mes <- append(mes,i)
                ano <- append(ano,y)
        }} 

valid_url <- function(url_in,t=2){
        con <- url(url_in)
        check <- suppressWarnings(try(open.connection(con,open="rt",timeout=t),silent=T)[1])
        suppressWarnings(try(close.connection(con),silent=T))
        ifelse(is.null(check), T, F)
}

true <- cbind(cbind(cbind(as.data.table(sapply(url,valid_url)),url),ano),mes)
names(true)[1] <- "valid"


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



spss <- cbind(as.data.table(sapply(spss$url,valid_url)),spss)
names(spss)[1] <- "valid"
spss <- spss[(spss$valid=="TRUE"),]
spss <- spss[order(spss$ano, spss$mes),]


destino <- c(paste("input/data_sav/ene_",spss$ano,"_",spss$mes,".sav", sep = ""))

# La siguiente función descarga sólo bases que no estén previamente guardadas.
for (i in seq_along(spss$url)){
        if(!file.exists(destino[i])){
                download.file(url = spss$url[i], destfile = destino[i], mode = "wb")
        }
        next
}


