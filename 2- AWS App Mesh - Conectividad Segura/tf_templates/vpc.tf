#Obtiene todas las zonas de disponbilidad que se encuentran disponibles
data "aws_availability_zones" "available" {
  state = "available"
}

#Crea una VPC principal para la creación de todos los recursos
resource "aws_vpc" "vpc_main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${var.environment}"
  }
}

#IGTW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id
}

# Subnets Publicas
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_public_${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
    "kubernetes.io/role/elb" = "1"
  }
}

#Subnetes privadas
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_private_${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Se crea Ip estatica para el natgateway
resource "aws_eip" "nat" {
  domain = "vpc"
}
# Se crea asocia la ip estatica al nat gateway, esta sera la ip que se vea en el trafico a internet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id
  depends_on = [aws_internet_gateway.igw]
  tags = { Name = "nat-gw-${var.project_id}" }
}
#Se crea la tabla de rutas publicas indicando que el trafico que vaya a internet se envie al internet gatway para que pueda salir, esto desde las subredes publicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "rt-public" }
}
#Asocia la tabla de rutas a las subnets publicas existentes, en este caso 2
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
#Creacion de tabla de ruta privada indicando que cuando va a internet se envie el trafico a la nat gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "rt-private" }
}
#Se asocia la tabla de rutas a la subnets privadas
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}