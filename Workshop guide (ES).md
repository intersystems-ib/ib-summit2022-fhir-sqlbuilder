# fhir-sqlbuilder-workshop
Bienvenid@ al taller de FHIR parte del InterSystems Iberia Summit 2022. 
Por estas alturas, la mayoría de los actores en el mundo sanitario entienden el propósito de FHIR (Fast Healthcare Interoperability Resources). Se trata de un estándar de intercambio electrónico de datos de salud. ¿Por qué es importante FHIR? En pocas palabras: si tiene dos fuentes de datos (sistemas) y necesita que "hablen" entre sí, FHIR puede ayudarlo a lograr ese objetivo. Bueno, la pregunta siguiente sería: ¿Qué más podemos hacer con los datos que estamos intercambiando? La respuesta obvia y telegráfica sería: analizar esos datos. A lo largo de este taller miraremos las capacidades de InterSystems IRIS for Health para interoperar y persistir datos en formato FHIR. Daremos también el paso siguiente, o sea, miraremos las capacidades de la plataforma para permitir las labores analíticas sobre un repositorio FHIR.

# ¿Qué necesitas instalar?
Se preparó este taller de manera a evitar dependencias para la asistencia. Para poder seguir la sesión con tu propio portátil se requiere:
* navegador web (chrome, safari, edge...)

Se recomienda también la instalación de:
* cliente Rest (Curl, Postman, ARC...)

# Actividades a realizar
A lo largo de este taller habremos de:
* Crear y configurar un endpoint/repositorio FHIR;
* Cargar datos de prueba en el endpoint;
* Crear una Producción de Interoperabilidad para nuestro endpoint FHIR;
* Customizar el comportamiento del endpoint;
* Analizar el contenido del repositorio mediante consultas SQL:
    * Análisis del repositorio
    * Definición de la transformación 
    * Proyección de la transformación a un esquema SQL.

# Información de contexto
Empezaremos la sessión con una instancia de InterSystems IRIS for Health previamente instalada en un servidor Windows alojado en la nube de AWS. A cada asistente se asignará una máquina virtual mediante su dirección de IP. En esta máquina tendremos los siguientes elementos relevantes:
* Instancia de InterSystems IRIS for Health 2022.3 (todavía no liberada);
* Unos 1.200 bundles fhir con un promedio de 800 recursos/bundle (en el sistema de ficheros);
    * Unos 850 de ellos ya subidos a la instancia
* Endpoint FHIR cargado con unos 850 bundles;
* Classe: IBSummit22.ResourceChangeBPL.cls
De manera a preparar debidamente el taller se propone abrir 3 pestañas en el navegador web con los siguientes enlaces:
* [Portal de Gestión] (http://xxx.xxx.xxx.xxx:52773/csp/sys/%25CSP.Portal.Home.zen?$NAMESPACE=DEMO&)
* [Terminal Web] (http://xxx.xxx.xxx.xxx:52773/terminal/)
* [FHIR SQL Builder] (http://xxx.xxx.xxx.xxx:52773/csp/fhirsql/index.csp#/)
Siempre que requerido usuario/contraseña deberemos usar: superuser/SYS
 
# Ejercicios
## Lanzar el proceso de Análisis en el SQL Builder 
Se trata de un paso previo que tardará unos minutos hasta que termine. Para aprovechar el tiempo lanzaremos ahora este proceso y volveremos al tema más adelante en este taller.
1.	Acceder al FHIR SQL Builder 
2.	Seleccionar **New** en el apartado Analyses
3.	Una vez dentro, pulsar **New** para crear un nuevo Analisis con los siguientes datos:
	- Name: DEMO
    - Host: localhost
	- Port: 52773
	- Credentials - Pulsar **New**, para crear unas nuevas credenciasles indicando:
	    - Name: Credentials
        - Username: superuser
        - Password: SYS
        - Save
    - FHIR Repository URL: /csp/healthshare/demo/fhir/r4
    - Save
4.	Percentage of records to analyze (1-100): 100
5.	Launch Analysis Task

Se trata de una tarea de larga duración. Podremos seguir la evolución de esta tarea a través de la información en ‘Percent Complete’. En cuanto terminemos los demás ejercicios ya se habrá terminado y nos permitirá seguir con los ejercicios de analítica.

## Crear y configurar un nuevo endpoint/repositorio FHIR
1.	Acceder al Portal de Gestión. Seleccionar el namespace DEMO.
2.	Ir a Health -> FHIR Configuration -> Server Configuration
3.	Tal y como podemos ver ya tenemos un endpoint creado – que se está analizando. Dejemos que se siga analizando. Creemos un nuevo endpoint/repositorio para seguir con los ejercicios. 
4.	Ir a ‘Add Endpoint’
    - Core FHIR package: hl7.fhir.r4.core@4.0.1
    - URL: /csp/healthshare/demo/fhir/r4a (default)
    - Additional packages (optional): hl7.fhir.us.core@3.1.0
    - Interactions strategy class: HS:FHIRServer.Storage.Json.InteractionsStrategy
    - Add
5.	Tardará unos segundos hasta que se termine de configurar.
6.	De manera a permitir accesos no autenticados editemos la configuración del endpoint. Ir al endpoint y editarlo:
    - En Debugging: Allow Unauthenticated Access
    - Update
7.	Comprobemos que tenemos nuestro endpoint bien definido. Solicitemos el recurso capability statement. 
    - Desde cualquier cliente Rest (o bien desde el navegador) hacer: 
        - GET http://xxx.xxx.xxx.xxx:52773/csp/healthshare/demo/fhir/r4a/metadata
8.	Comprobemos que nuestro endpoint no contiene datos. 
    - Desde el cliente Rest hacer:
        - GET http://xxx.xxx.xxx.xxx:52773/csp/healthshare/demo/fhir/r4a/Patient?_summary=count
    - En Total vemos 0 (zero) pacientes
9.	Carguemos nuestro repositorio con 10 fhir bundles conteniendo datos clínicos de 10 pacientes distintos.
a.	Ir al Terminal Web y ejecutar los comandos:
```
Zn “DEMO”
do ##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles("C:\fhir_bundles","FHIRSERVER","/csp/healthshare/demo/fhir/r4a")
```
10.	Comprobemos que la carga ha sido exitosa buscando todos los pacientes en el endpoint:
    - Desde cualquier el cliente Rest hacer: 
        - GET http://xxx.xxx.xxx.xxx:52773/csp/healthshare/demo/fhir/r4a/Patient
11.	Tenemos nuestro servidor FHIR totalmente operativo

## Crear una producción de interoperabilidad para nuestro endpoint/repositorio FHIR
1.	Acceder al Portal de Gestión
2.	Ir a **Interoperability -> Configure -> Production**
3.	Usemos la producción (default) DEMOPKG.FoundationProduction
    - Añadir un Business Operation de la clase: HS.FHIRServer.Interop.Operation 
        - Activar
    - Añadir un Business Service de la clase: HS.FHIRServer.Interop.Service
        - Activar
    - Iniciar la Producción
4.	Ir a **Health -> FHIR Configuration -> Server Configuration**
    - En /csp/healthshare/demo/fhir/r4a, editar:
        - En Interoperability -> Service Config Name: HS.FHIRServer.Interop.Service
    - Update
5.	De manera a comprobar el cambio, lanzar la siguiente petición desde el cliente Rest:
    - GET http://xxx.xxx.xxx.xxx:52773/csp/healthshare/demo/fhir/r4a/Patient/1
6.	En el Portal de Gestión, ir a **Interoperability -> View -> Messages**, para abrir el Visor de Mensajes y comprobar el flujo de los mensajes. Comprobemos que en la traza tenemos el par *HS.FHIRServer.Interop.Request* y *HS.FHIRServer.Interop.Response*. Sin embargo no vemos el recurso que sacamos del servidor. Para tenerlo en la traza hagamos los siguientes cambios, volviendo a la producción **Interoperability -> Configure -> Production**:
    - Añadir un Business Operation de la clase: *HS.Util.Trace.Operations*
        - Activar
    - En el componente HS.FHIRServer.Interop.Operation configurar:
        - TraceOperations: *FULL*
        - Aplicar
7.	De manera a comprobar el cambio, volvamos a lanzar la siguiente petición desde el cliente Rest:
    - GET http://xxx.xxx.xxx.xxx:52773/csp/healthshare/demo/fhir/r4a/Patient/1
8.	Ahora que ya tenemos nuestra producción podemos manipular los requests/responses a nuestro servidor. Para ello incorporemos a la producción el componente:
    - Business Process: *IBSummit22.ResourceChangeBPL*
        - Activar
    - En el Business Service *HS.FHIRServer.Interop.Service* configurar lo siguiente parámetro: 
        - Nombre de configuración de destino: IBSummit22.ResourceChangeBPL
        - Aplicar
9.	Editemos el BPL que hemos añadido y habilitemos el código que tenemos desactivado. Para ello: 
    - En el Business Process *IBSummit22.ResourceChangeBPL* acceder al parámetro Nombre de Clase. Pinchar la lupa.
    - Resumen: Se trata de un sencillo ejemplo de anonimización. Al recibir la respuesta del servidor comprobamos si la operación solicitada es un GET y si el recurso solicitado es el Paciente. Siendo así, le quitamos el nombre y cambiamos el género a ‘unknown’. 
    - En el BPL veamos el contenido de la actividad ‘Code’. 
        - En la actividad ‘Code’ quitar el estado desactivado.
        - Compilar
10.	De manera a comprobar el cambio, volvamos a lanzar la siguiente petición desde el cliente Rest:
    - GET http://xxx.xxx.xxx.xxx:52773/csp/healthshare/demo/fhir/r4a/Patient/1
    - Comprobemos el resultado.

## Volviendo al SQL Builder
Ya tenemos el análisis terminado en nuestro endpoint/repositorio - URL: /csp/healthshare/demo/fhir/r4. Nos apoyaremos en este repositorio para seguir con los ejercicios.
1.	Acceder al FHIR SQL Builder 
2.	Comprobemos que el Percent Complete es 100% y el Status es Completed. Ahora podremos seguir con las labores de analítica sobre nuestro endpoint/repositorio. 
3.	Crear una nueva transformación:
    - Name: DEMOTRANSFORM
    - Analysis: DEMO (que acabamos de generar)
    - Create Transformation Specification
4.	A la mano izquierda se abre un árbol conteniendo los recursos existentes en el repositorio
5.	Podemos expandir uno de los recursos y comprobar las ocurrencias de cada elemento del recurso
6.	Crear especificación de transformación con (al seleccionar, recordad pulsar **Add To Projection**:
    - Patient: 
        - BirthDate (Index)
        - Gender (Index) (ver histograma)
        - IdentifierTypeCodingCode (Index)
        - IdentifierTypeCodingDisplay
        - IdentifierValue (Index)
        - NameFamily
            - La propiedad name es un array. Podemos definir filtros en estos casos:
                - En Filter, pinchar en name y ponerle use – equals - official 
        - NameGiven.
    - Address, como tabla secundaria del paciente: 
        - Ojo: el nombre de la tabla será Address y no Addresss (eliminar s sobrante)
        - City
        - Country
        - Line 
        - PostalCode
        - State
    - Observation: 
        - CodeCodingCode (Code) (Index)
        - CodeCodingDisplay (Display)
        - SubjectReference (Subject) (Index)
        - EncounterReference (Encounter) (Index)
        - ValueQuantityValue (Value).
    - Encounter:
        - ClassCode (Index)
        - PeriodEnd
        - PeriodStart
        - SubjectReference (Subject) (Index).
    - Revisar y done
7.  Crear una nueva proyección con:
    - FHIR Repository
        - Elegir el analisis lanzamos al inicio y que ya se terminó
    - Transformation Specification
        - Elegir la transformación que hicimos en paso anterior
    - Package Name
        - Usaremos DEMO como esquema SQL al que proyectar nuestra transformación
    - Launch Projection Task
8.	Acceder al Portal de Gestión en namespace DEMO
9.	Ir a System Explorer -> SQL
10.	En Filter ponerle DEMO*
11.	Abrir la pestaña Tables
12.	Podremos hacer algunos queries para comprobar el número de recursos en nuestro repositorio:
    - SELECT count(*) FROM DEMO.Observation
    - SELECT count(*) FROM DEMO.Patient
    - SELECT count(*) FROM DEMO.Encounter
13.	Podremos también simular alguna analítica:
    - Valores de triglicéridos por genero … 
        - SELECT Count(*) as "# Count",P.Gender, AVG(value) as "Avg Value", MAX(value) as "Max Value", MIN(value) as "Min Value" FROM DEMO.Observation Ob, DEMO.Patient P WHERE (Ob.Subject=P.Key) and (Code='2571-8') GROUP BY p.Gender
    - Pacientes en riesgo de enfermedad debido a altos niveles de triglicéridos
        - SELECT P.* FROM DEMO.Observation Ob, DEMO.Patient P WHERE (Ob.Subject=P.Key) and (Code='2571-8') and Value>150 Group by p.ID
    - Pacientes de genero masculino con Panel de ARN del SARS-CoV-2 (COVID-19)
        - SELECT COUNT(*) FROM DEMO.Patient P LEFT OUTER JOIN DEMO.Observation Ob ON (P.Key=Ob.Subject) WHERE (Code='94531-1') AND (P.Gender='male')
14.	De manera a que veamos la sincronización del repositorio fhir con la proyección SQL, lanzemos un proceso de carga masiva de bundles fhir. 
```
Zn “DEMO”
do ##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles("C:\fhir_bundles_300","FHIRSERVER","/csp/healthshare/demo/fhir/r4")
```
15.	Mientras se están cargando los 305 bundles fhir – algo que tardará unos minutos – aprovechemos para repetir las búsquedas SQL y comprobar la actualización en tiempo real de las tablas SQL.

## Cierre del taller
Para terminar, haremos una demostración del consumo de datos fhir proyectados a SQL. Para ello usaremos el conector IRIS de PowerBI. La hará el ponente desde su laptop.
¡Enhorabuena! Has terminado el viaje del paciente a la poblacion.
