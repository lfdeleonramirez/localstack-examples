# Rol IAM para el Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
  policy_arn = each.value
  role = aws_iam_role.eks_cluster_role.name
}

# Cluster EKS
resource "aws_eks_cluster" "main" {
  name     = "eks-app-mesh-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.30"
  vpc_config {
    subnet_ids = concat( aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Rol IAM para Nodos
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
# Crea permisos para para que los nodos creados puedan vincularse al cluster
resource "aws_iam_role_policy_attachment" "workers" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_node_role.name
}
#Crea los permisos para que puedan operar correctamente el routing dentro del cluster
resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}
#Brinda permisos para obtener imagenes de ECR
resource "aws_iam_role_policy_attachment" "registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Nodegroups
resource "aws_eks_node_group" "main" {
  
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "ng-backend-${var.environment}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private[*].id 
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  instance_types = [var.node_group_instance]
  depends_on = [
    aws_iam_role_policy_attachment.workers,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.registry,
  ]
  
}