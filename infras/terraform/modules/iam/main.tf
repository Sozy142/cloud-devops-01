# ==============================================================================
# IAM ROLE
# ==========

resource "aws_iam_role" "nat_instance_role" {
  name = "${var.project_name}-nat-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-nat-instance-role" }
  )
}

resource "aws_iam_role_policy_attachment" "nat_ssm_core" {
  role = aws_iam_role.nat_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "${var.project_name}-nat-instance-profile"
  role = aws_iam_role.nat_instance_role.name
}


resource "aws_iam_role" "jenkins_controller_role" {
  name = "${var.project_name}-controller-role"

  # Assume Role Policy
  # ec2.amazonaws.com
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-controller-role" }
  )
}

# 2.
# AmazonSSMManagedInstanceCore
# Allow EC2 connect SSM Session Manage

resource "aws_iam_role_policy_attachment" "controller_ssm_policy" {
  role       = aws_iam_role.jenkins_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. Instance Profile for EC2
resource "aws_iam_instance_profile" "jenkins_controller_profile" {
  name = "${var.project_name}-controller-profile"
  role = aws_iam_role.jenkins_controller_role.name

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-controller-profile" }
  )
}

# EC2 Policy for Controller to launch/terminate Agent instances
resource "aws_iam_role_policy" "controller_ec2_policy" {
  name = "${var.project_name}-controller-ec2-policy"
  role = aws_iam_role.jenkins_controller_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DescribeImages",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions",
          "ec2:DescribeVpcs",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:GetConsoleOutput",
          "iam:CreateServiceLinkedRole",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "controller_ec2_readonly" {
  role       = aws_iam_role.jenkins_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# IAM Role for agent
resource "aws_iam_role" "jenkins_agent_role" {
  name = "${var.project_name}-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-agent-role" }
  )
}


resource "aws_iam_role_policy_attachment" "agent_ssm_policy" {
  role       = aws_iam_role.jenkins_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "${var.project_name}-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-agent-profile" }
  )
}