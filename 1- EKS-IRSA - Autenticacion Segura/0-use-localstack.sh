docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e SERVICES=iam,ec2,s3,sts,lambda,cloudformation \
  localstack/localstack
