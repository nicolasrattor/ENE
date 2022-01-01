# Encuesta Nacional de Empleo (ENE)

La Encuesta Nacional de Empleo (ENE) tiene como objetivo clasificar y caracterizar a la población en edad de trabajar, con residencia habitual en Chile, según su condición de actividad. La ENE es una de las encuestas de hogares más antiguas de América Latina, publicando datos de manera periódica desde 1966. Existen datos disponibles en la página Web del INE para las personas usuarias de información desde 2010 a la fecha, utilizando trimestres móviles como periodo de referencia para construir las estimaciones de los datos. Esta características permite conocer la evolución en el tiempo de los principales indicadores de empleo, así como también construir otros nuevos.

![Detalle de bases ENE en sitio INE](input/img/link.png?raw=true)


## Descarga y carga de datos

* Descarga de bases de datos
    * [en formato csv y sav](processing/00_download.R)
    
* Cargar y compilar en Rdata
    * [crear tres archivos Rdata con todas las bases](processing/01_cargarbases.R)


## Análisis

* Horas de trabajo semanales 2010-2021
    * [Asalariados sector privado](analysis/01_horas_trabajo_asalariados_priv.R)
    
* Ocupados en agricultura
    * [Ocupados en agricultura](analysis/02_agro.R)
    
* Trabajadoras de casa particular
    * [Porcentaje de informales](analysis/03_tcpinformalidad.R)


## Gráficos resultantes

![](output/graficos/horas/horas_trabajo_priv.png?raw=true)

![](output/graficos/agro/ocupados_agricultura.png?raw=true)

![](output/graficos/tcp/Gráfico_informales_porcentaje.png?raw=true)
