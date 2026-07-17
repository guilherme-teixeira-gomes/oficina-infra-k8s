variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "oficina-eks"
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "Tipo de instância dos nodes"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Número desejado de nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Mínimo de nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Máximo de nodes"
  type        = number
  default     = 3
}
