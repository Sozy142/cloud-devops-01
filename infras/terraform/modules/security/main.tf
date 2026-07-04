resource "aws_security_group" "nat_sg" {
  name        = "${var.project_name}-nat-sg"
  description = "Allow inbound traffic from private subnet to internet via NAT instance"
  vpc_id      = var.vpc_id

  # Inbound: Accept all traffic originating from the Private Subnet CIDR
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-nat-sg" }
  )
}


# Jenkins controller SG
resource "aws_security_group" "jenkins_controller_sg" {
  name        = "${var.project_name}-jenkins-controller-sg"
  description = "Security group for Jenkins Controller"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-jenkins-controller-sg" }
  )
}

resource "aws_security_group" "jenkins_agent_sg" {
  name        = "${var.project_name}-jenkins-agent-sg"
  description = "Security group for Jenkins Workers/Agents inside Private Subnet"
  vpc_id      = var.vpc_id

  # Outbound: Allow all outbound traffic to connect to Controller (Port 50000) and internet via NAT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-jenkins-agent-sg" }
  )
}

# ==============================================================================
# 5. APPLICATION LOAD BALANCER SECURITY GROUP
# ==============================================================================
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB - only allow GitHub webhook"
  vpc_id      = var.vpc_id

  # Inbound: only allow port 80 from internet (GitHub webhook)
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "192.30.252.0/22",
      "185.199.108.0/22",
      "140.82.112.0/20",
      "143.55.64.0/20"
    ]
    ipv6_cidr_blocks = [
      "2a0a:a440::/29",
      "2606:50c0::/32"
    ]
    description = "Allow GitHub webhook traffic"
  }

  # Outbound: Allow ALB to forward traffic inside the VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-alb-sg" }
  )
}


# ==============================================================================
# 4. STANDALONE RULES (To prevent Cycle Dependency errors)
# ==============================================================================
# Inbound Rule: Allow Jenkins Agents to connect to Controller via JNLP port 50000

resource "aws_security_group_rule" "allow_agent_to_controller_50000" {
  type                     = "ingress"
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_controller_sg.id
  source_security_group_id = aws_security_group.jenkins_agent_sg.id
}

resource "aws_security_group_rule" "allow_controller_ssh_to_agent" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_agent_sg.id
  source_security_group_id = aws_security_group.jenkins_controller_sg.id
  description              = "Allow Controller to SSH into Agent for EC2 Plugin bootstrap"
}

# Inbound Rule: Allow HTTP traffic on port 8080 strictly from the Application Load Balancer
resource "aws_security_group_rule" "allow_alb_to_controller_8080" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_controller_sg.id
  source_security_group_id = aws_security_group.alb_sg.id # allow traffic from ALB
}
