# ORQUESTACIÓN Y SEGURIDAD DE IDENTIDAD (EKS + IRSA) 

## Información del Proyecto
* **ID:** EKS-IRSA-SEC-001
* **Área:** Infraestructura y Seguridad

## Estándar de nombrado en recursos de red
Con el fin de identificar de forma rápida a que AZ pertenece cada subnet, se crean con el siguiente patrón `subnet_<tipo>_<zona>`

## Mecanismo de Seguridad (IRSA)
Se utiliza OIDC evitando así el uso de claves, que en algún momento deban ser rotadas.
1. EKS emite token JWT al Pod.
2. Pod asume rol `role-irsa-prod` via STS.
3. IAM valida que el token venga de `system:serviceaccount:microservicios:s3-access-sa`.

## Despliegue
Se crean archivos en bash para la creación de los recursos, a continuación se detalla las acciones realizadas en cada uno de ellos

1. 1-init.sh : Descargar los plugins despues de cambios y prepara las dependencias requeridas
2. 2-validate.sh: Valida que el conjunto de plantillas de terraform se encuentren correctas
3. 3-destroy.sh: Elimina los recursos creados por completo
4. 4-execute-plan.sh: Valida que el conjunto de plantillas de terraform se encuentren correctas
5. 5-apply.sh: Realiza la creación de los recursos en la cuenta de AWS especificada

## Pruebas Locales
Se crea un script llamado `0-use-localstack.sh` el cual permite realizar la creacion de un contenedor con la aplicación localstack, la cual permite emular los servicios de cloud localmente, para no incurrir en gastos, en el archivo main.tf se encuentran propiedades las cuales quedan configuradas para pruebas en ambiente local.

## NOTA ADICIONAL
Posterior a la creación de los recursos se podrá crear el recurso en Kubernetes para que el namespace tenga acceso al bucket

# YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-service-account
  namespace: microservicios
  annotations:
    [eks.amazonaws.com/role-arn](https://eks.amazonaws.com/role-arn): <arn del irsa_role>