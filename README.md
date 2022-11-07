# fhir-sqlbuilder-demo
Esta es una demostración de FHIR SQL Builder
 
# Información de fondo
FHIR SQL Builder es una función que aún no está disponible en el producto. Esta demostración es parte del Programa de Acceso Anticipado (EAP). Es una manera de dar forma al futuro ‘FHIR Analytics’ proporcionando comentarios sobre las próximas capacidades de IRIS for Health que se lanzará próximamente. Si encuentra algún problema, háganoslo saber.
Al ser un EAP, deberá tener acceso a una versión todavía no liberada de InterSystems IRIS for Health. Consúltenos para obtener la imagen y licencia adecuadas.
 
# Preparación de imagen
Descargue el último kit disponible (contenedor). Mientras no esté liberada la versión correspondiente, la única forma de obtener un kit con esta función será mediante contacto directo con InterSystems. Estos son los pasos de configuración:
* Descargue el último contenedor
* Descomprimir el archivo: gzip -d irishealth-202X.X.0FHIRSQL.XX.0-docker.tar.gz
* Cargue el archivo para crear una imagen de Docker (suponiendo que Docker ya se esté ejecutando): Docker load -i irishealth-202X.X.0FHIRSQL.XX.0-docker.tar
* Cambie el archivo Docker adjunto para usar esta nueva imagen
 
# Requisitos
No necesita ninguna otra herramienta para usar FHIR SQL Builder. Sin embargo, es posible que desee utilizar algún cliente SQL externo para acceder a su proyección SQL. Si ese es el caso, puede descargar su controlador JDBC [aquí] (https://github.com/intersystems-community/iris-driver-distribution/tree/main/ODBC).
Como sugerencia puede usar DBeaver. Lo encontrará [aquí](https://dbeaver.io/download/).
 
# Configuración
```
docker-compose build
Docker-compose up -d
````
 
## Datos iniciales:
En el script de creación de este entorno ya se cargan 10 pacientes (bundles). El contenido de esta carga está disponible en la carpeta /fhirdata.
 
### Usando el SQL Builder
* Acceder a http://localhost:52773/csp/fhirsql/index.csp
* Crear una entrada de Análisis y elija su Repositorio FHIR - DEMO, en este caso. Pude tardar hasta 1 minuto, dependiendo de los recursos disponibles.
* Crear especificación de transformación con:
    * Patient – BirthDate, Gender, IdentifierTypeCodingCode, IdentifierTypeCodingDisplay, IdentifierValue, NameFamily, NameGiven.
    * Address, como tabla secundaria del paciente: City, Country,  GeolocationLatitudeValueDecimal (Latitude), Line, GeolocationLongitudeValueDecimal (Longitude), PostalCode, State.
    * Observation – CodeCodingCode (Code), CodeCodingDisplay (Display), SubjectReference (Subject), EncounterReference (Encounter), ValueQuantityValue (Value).
   * Encounter – ClassCode, PeriodEnd, PeriodStart, SubjectReference (Subject).
    * Revisar y enviar
*Cree una Proyección para su Transformación – llámela DEMO.
 
En esta etapa, puede realizar algunas consultas para verificar los datos
 
### Importe nuevos recursos (bundles) y verifique las actualizaciones en tiempo real
```
Zn “DEMO”
do ##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles("/irisdev/fhirdata2test/","FHIRSERVER","/csp/healthshare/demo/fhir/r4")
```
Realice algunas consultas para verificar la actualización en vivo.
 
### Cargar código fuente para una tabla de búsqueda y una vista
Nos sirve como ejemplo para la traducción/mapeo de códigos entre distintos sistemas. Nos permite mezclar datos de la proyección del repositorio FHIR con datos persistentes en otros repositorios SQL.
```
zn "DEMO"
do $SYSTEM.OBJ.LoadDir("/irisdev/src/isi/sqlbuilder/", "ck", .errorlog, 1)
````
 
Vaya a *Explorador del sistema > SQL*:
* Seleccione el espacio de nombres DEMO
* Ejecutar las siguientes consultas
    * insert  into isi_sqlbuilder.CODEMAPPING values ('8302-2', 'testCode')
    * insert into isi_sqlbuilder.CODEMAPPING values ('72514-3', 'anotherTestCode')
 
Ahora puede ejecutar SELECT * FROM isi_sqlbuilder.viewMappedObs para verificar la traducción del código en acción.