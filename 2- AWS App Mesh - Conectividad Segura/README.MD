
# Infraestructura Cloud Native AWS - Proyecto Secure Mesh

Este proyecto despliega una arquitectura EKS privada integrada con AWS App Mesh para garantizar una comunicación Zero-Trust mediante mTLS estricto.
Cabe mencionar que no fue posible verificar la creación del recurso, ya que AWS no permite creación de nuevas mayas, se sugiere la migración a VPC Lattice.

## Decisiones Arquitectónicas
1.  **Red (VPC):** Teniendo en cuenta escencialmente la alta disponibilidad se crea un topología multi AZ con dos zonas de disponibilidad, en dichas zonas existen subredes públicas y privadas, con NAT Gateway para que los recursos en las redes privadas puedan llegar al internet gateway y salir a internet.
2.  **Service Mesh (mTLS):** Se crea el recurso en AWS App Mesh para el manejo y control de la carga entre pods.
    * **Virtual Node:** Configurado en modo `STRICT`.
    * **Identidad:** Se delega la gestión de certificados a ACM (AWS Certificate Manager), evitando la rotación manual de certificados TLS.

## Integracion a los pods de EKS
1. Se debe integrar en el deployment de los servicios las siguientes etiquetas para que estos puedan utilizar los componentes logicos del app mesh y este pueda utilizar los recursos ya creados y la imágen que estará utilizando el onvoy proxy
  **YAML**
  metadata:
  annotations:
    appmesh.k8s.aws/mesh: myproject-mesh
    appmesh.k8s.aws/virtualNode: api-customer-vn


## Despliegue
Se crean archivos en bash para la creación de los recursos, a continuación se detalla las acciones realizadas en cada uno de ellos

1. 1-init.sh : Descargar los plugins despues de cambios y prepara las dependencias requeridas
2. 2-validate.sh: Valida que el conjunto de plantillas de terraform se encuentren correctas
3. 3-destroy.sh: Elimina los recursos creados por completo
4. 4-execute-plan.sh: Valida que el conjunto de plantillas de terraform se encuentren correctas
5. 5-apply.sh: Realiza la creación de los recursos en la cuenta de AWS especificada

## Pruebas Locales
Se crea un script llamado `0-use-localstack.sh` el cual permite realizar la creacion de un contenedor con la aplicación localstack, la cual permite emular los servicios de cloud localmente, para no incurrir en gastos, en el archivo main.tf se encuentran propiedades las cuales quedan configuradas para pruebas en ambiente local.

## NOTA:
El 30 de septiembre de 2026 AWS dejará de ofrecer soporte para AWS App Mesh
