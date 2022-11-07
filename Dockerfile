# ARG IMAGE=intersystems/irishealth:2022.1.0FHIRSQL.110.0
ARG IMAGE=intersystems/irishealth:2022.3.0FHIRSQL.60.0
FROM $IMAGE

USER root

# change ownership
RUN mkdir -p /opt/irisapp
RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
WORKDIR /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

# copy license
COPY iris.key /usr/irissys/mgr/iris.key

# copy source
COPY iris.script iris.script

# copy fhir data
COPY /fhirdata /opt/irisapp/fhirdata

# run iris.script
RUN iris start IRIS \
    && iris session IRIS < /opt/irisapp/iris.script \
    && iris stop IRIS quietly