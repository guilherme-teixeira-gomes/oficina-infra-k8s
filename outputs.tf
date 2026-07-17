output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.oficina.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do Kubernetes"
  value       = aws_eks_cluster.oficina.endpoint
}

output "cluster_certificate_authority" {
  description = "CA do cluster (base64)"
  value       = aws_eks_cluster.oficina.certificate_authority[0].data
  sensitive   = true
}

output "configure_kubectl" {
  description = "Comando para configurar o kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.oficina.name}"
}
