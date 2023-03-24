#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "web-app-node" {
  name = "terraform-eks-web-app-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "web-app-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.web-app-node.name
}

resource "aws_iam_role_policy_attachment" "web-app-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.web-app-node.name
}

resource "aws_iam_role_policy_attachment" "web-app-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.web-app-node.name
}

resource "aws_eks_node_group" "web-app" {
  cluster_name    = aws_eks_cluster.web-app.name
  node_group_name = "web-app"
  node_role_arn   = aws_iam_role.web-app-node.arn
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
  instance_types = ["t3.small"]
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  labels = {
    role = "web-app"
  }

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.web-app-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.web-app-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.web-app-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}