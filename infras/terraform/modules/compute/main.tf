# NAT Instance
resource "aws_instance" "nat_instance" {
  ami                         = var.ami_id
  instance_type               = var.nat_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.nat_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = var.nat_instance_profile
  source_dest_check           = false

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-nat-instance" }
  )
}

# Controller Instance
resource "aws_instance" "controller_instance" {
  ami                         = var.ami_id
  instance_type               = var.controller_instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.controller_sg_id]
  associate_public_ip_address = false
  iam_instance_profile        = var.controller_instance_profile
  key_name                    = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-controller-instance" }
  )
}

# EBS Volume
resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = aws_instance.controller_instance.availability_zone
  size              = 10
  type              = "gp3"
  encrypted         = true
  snapshot_id       = var.jenkins_snapshot_id

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-jenkins-data" }
  )
}

# EBS Attachment
resource "aws_volume_attachment" "jenkins_data_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.jenkins_data.id
  instance_id = aws_instance.controller_instance.id
}