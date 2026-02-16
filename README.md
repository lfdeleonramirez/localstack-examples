# localstack-examples
En este repositorio se podrán encontrar diversos ejemplos de arquitecturas creadas y verificadas con localstack, para iniciar tus pruebas en ambiente local será necesario unicamente ejecutar esto, todos los ejemplos serán realizados en terraform para conservar el principio de multinube


docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e SERVICES=iam,ec2,s3,sts,lambda,cloudformation \
  localstack/localstack
