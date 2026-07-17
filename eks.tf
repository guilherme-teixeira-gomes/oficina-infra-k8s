locals {
  vpc_id             = data.terraform_remote_state.database.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.database.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.database.outputs.public_subnet_ids
}

resource "aws_eks_cluster" "oficina" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(local.private_subnet_ids, local.public_subnet_ids)
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_eks_node_group" "oficina" {
  cluster_name    = aws_eks_cluster.oficina.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = local.private_subnet_ids

  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy
  ]
}

# NAT Gateway para os nodes privados acessarem a internet (pull de imagens)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "oficina-nat-eip" }
}

resource "aws_nat_gateway" "oficina" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.public_subnet_ids[0]
  tags          = { Name = "oficina-nat" }
}

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.oficina.id
  }

  tags = { Name = "oficina-private-rt" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = local.private_subnet_ids[0]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = local.private_subnet_ids[1]
  route_table_id = aws_route_table.private.id
}
