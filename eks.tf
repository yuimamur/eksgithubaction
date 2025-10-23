resource "aws_security_group" "eks" {
  name        = "${var.cluster_name}-sg"
  vpc_id      = aws_vpc.this.id
  description = "EKS cluster security group"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = [for s in aws_subnet.public : s.id]
    endpoint_private_access = false
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy
  ]
}

resource "aws_eks_node_group" "single" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [for s in aws_subnet.public : s.id]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  instance_types = [var.node_instance_type]
  ami_type       = "AL2023_x86_64_STANDARD"

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.this
  ]
}

resource "aws_eks_node_group" "tools" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-tools-nodegroup"
  node_role_arn   = aws_iam_role.tools_node_group.arn
  subnet_ids      = [for s in aws_subnet.public : s.id]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  capacity_type  = "SPOT"
  instance_types = [var.tools_node_instance_type]
  ami_type       = "AL2023_x86_64_STANDARD"

  depends_on = [
    aws_iam_role_policy_attachment.tools_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tools_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tools_node_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.this
  ]
}