#Creacion del bucket a utilizar
resource "aws_s3_bucket" "backend_data" {
  bucket_prefix = "data-${lower(var.s3_name)}"
  force_destroy = true
}
#Obtiene la url de OIDC del cluster de EKS
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
#Politica de acceso al bucket desde el pod
resource "aws_iam_policy" "s3_access" {
  name = "policy-s3-access-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Effect = "Allow"
      Resource = [
        aws_s3_bucket.backend_data.arn,
        "${aws_s3_bucket.backend_data.arn}/*"
      ]
    }]
  })
}
#Rol para permitir que sea posible asumir el rol por la identidad 
resource "aws_iam_role" "irsa_role" {
  name = "role-irsa-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_attach" {
  role = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}