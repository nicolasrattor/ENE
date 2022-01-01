
ifelse(
        dir.exists("input/data_Rdata"),
        print("Directorio existe"),
        dir.create("input/data_Rdata")
)

## Cargar bases

data_csv_long <- list.files("input/data_csv",full.names = TRUE)
data_csv_short <- stringr::str_remove_all(list.files("input/data_csv"),".csv")

# Primera parte
for(i in 1:71){
        assign(
        data_csv_short[i],
        read.csv(data_csv_long[i])  
        )
}

save(list=ls(pattern = "ene_"), file="input/data_Rdata/bases_ENE_1.Rdata")

rm(list=ls(pattern = "ene_"))


# Segunda parte csv
for(i in 72:90){
        assign(data_csv_short[i],
               readr::read_csv(data_csv_long[i]))
  
}


# Segunda parte spss continuacion
data_sav_long <- list.files("input/data_sav",full.names = TRUE)
data_sav_short <- stringr::str_remove_all(list.files("input/data_sav"),".sav")

for(i in 1:length(data_sav_long)){
        assign(
                data_sav_short[i],
                haven::read_sav(data_sav_long[i])  
        )
}

for(i in 120){
                assign(data_csv_short[i],
                       readr::read_csv2(data_csv_long[i]))
}


save(list=ls(pattern = "ene_"), file="input/data_Rdata/bases_ENE_2.Rdata")

rm(list=ls(pattern = "ene_"))




# Tercera parte
for(i in 128:length(data_csv_long)){
        assign(
                data_csv_short[i],
                readr::read_csv2(data_csv_long[i])  
        )
}

save(list=ls(pattern = "ene_"), file="input/data_Rdata/bases_ENE_3.Rdata")

rm(list=ls(pattern = "ene_"))



