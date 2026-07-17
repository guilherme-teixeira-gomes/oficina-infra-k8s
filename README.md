# Oficina Infra K8s

Infraestrutura como Código do cluster Kubernetes — Tech Challenge Fase 3 (Grupo MotorMind).

## Propósito

Provisiona via Terraform:

- **Cluster EKS** (Kubernetes 1.29) com endpoint público e privado
- **Node Group** com auto-scaling (1 a 3 nodes t3.small)
- **IAM Roles** do cluster e dos nodes
- **NAT Gateway** para os nodes privados baixarem imagens

Consome a VPC criada pelo repositório [`oficina-infra-database`](https://github.com/guilherme-teixeira-gomes/oficina-infra-database) via Terraform remote state.

## Tecnologias

- Terraform >= 1.5
- AWS EKS 1.29
- Backend S3 para estado remoto

## Arquitetura

```
                    ┌──────── EKS Control Plane ────────┐
                    │      (gerenciado pela AWS)         │
                    └──────────────┬─────────────────────┘
                                   │
┌─────────────────── VPC (repo oficina-infra-database) ──────────┐
│                                  │                              │
│  ┌── private-a ────────┐  ┌── private-b ────────┐               │
│  │  ┌────────────┐     │  │  ┌────────────┐     │               │
│  │  │ Node t3.sm │     │  │  │ Node t3.sm │     │  1-3 nodes    │
│  │  └────────────┘     │  │  └────────────┘     │  auto-scaling │
│  └─────────┬───────────┘  └──────────────────────               │
│            │ NAT Gateway (saída internet)                       │
│  ┌── public-a ─────────────────────────────────┐                │
│  │  Load Balancers dos Services                │                │
│  └─────────────────────────────────────────────┘                │
└──────────────────────────────────────────────────────────────────┘
```

## Recursos criados

| Recurso | Descrição |
|---------|-----------|
| aws_eks_cluster | Cluster Kubernetes 1.29 |
| aws_eks_node_group | Nodes t3.small com scaling 1-3 |
| aws_iam_role (x2) | Roles do cluster e dos nodes |
| aws_iam_role_policy_attachment (x4) | Políticas gerenciadas AWS |
| aws_nat_gateway + aws_eip | Saída de internet dos nodes |
| aws_route_table | Rotas das subnets privadas |

## Como aplicar

### Pré-requisitos

1. Repositório `oficina-infra-database` aplicado primeiro (cria a VPC)
2. Bucket S3 `oficina-terraform-state` existente

### Localmente

```bash
terraform init
terraform plan
terraform apply
```

### Conectar o kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name oficina-eks
kubectl get nodes
```

### Via CI/CD

- **Pull Request** → `fmt`, `validate` e `plan`
- **Push na main** → `apply` automático

Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` (se aplicável).

## Custos e destruição

O EKS custa ~US$ 0,10/hora (control plane) + nodes. **Destrua quando não estiver usando:**

```bash
terraform destroy
```
