# MOVILIDAD Y ANÁLISIS DE DATOS (DMS + ATHENA) 

# Arquitectura
Se realiza el proyecto desde cero partiendo desde elementos básicos para el funcionamiento de la arquitectura

1. Redes (VPC, Subnets, Nat Gateways, Internet Gateways, ElasticIP): Se define la estructura de red para poder alojar dentro de ella los recursos creados
2. Base de datos (RDS, Secrets Manager): Se crean los clusteres a utilizar, se piensa en instancias reservadas para mantener el funcionamiento de la base de datos y la creacion de secrets manager para que no existan contraseñas en codigo, estas se generan automaticamente y de forma aleatoria
3. Lago de datos (S3, ATHENA, DMS): Se generan los buckets correspondientes, tanto para almacenar la migración de los datos desde el rds a formato parquet en s3, así como el almacenamiento de los querys generados en athena, se crean las tablas para consulta

## Despliegue
Se crean archivos en bash para la creación de los recursos, a continuación se detalla las acciones realizadas en cada uno de ellos

1. 1-init.sh : Descargar los plugins despues de cambios y prepara las dependencias requeridas
2. 2-validate.sh: Valida que el conjunto de plantillas de terraform se encuentren correctas
3. 3-destroy.sh: Elimina los recursos creados por completo
4. 4-execute-plan.sh: Valida que el conjunto de plantillas de terraform se encuentren correctas
5. 5-apply.sh: Realiza la creación de los recursos en la cuenta de AWS especificada

## Pruebas Locales
Se crea un script llamado `0-use-localstack.sh` el cual permite realizar la creacion de un contenedor con la aplicación localstack, la cual permite emular los servicios de cloud localmente, para no incurrir en gastos, en el archivo main.tf se encuentran propiedades las cuales quedan configuradas para pruebas en ambiente local.


